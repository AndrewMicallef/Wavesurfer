classdef Display < ws.system.Subsystem & ws.EventSubscriber
    %Display Manages the display and update of one or more Scope objects.
    
    properties (Dependent = true)
        UpdateRate  % the rate at which the scopes are updated, in Hz
    end
    
    properties    
        XAutoScroll = false  % if true, x limits of all scopes will change to accomodate the data as it is acquired
    end
    
    properties (Dependent = true)
        XOffset  % the x coord at the left edge of the scope windows
    end

    properties (Dependent = true)
        XSpan  % the trace duration shown in the scope windows
    end
    
    properties (Dependent=true)
        IsXSpanSlavedToAcquistionDuration
          % if true, the x span for all the scopes is set to the acquisiton
          % trial duration
    end
    
    properties (Access=protected)
        IsXSpanSlavedToAcquistionDuration_ = true
          % if true, the x span for all the scopes is set to the acquisiton
          % trial duration
    end
    
    properties (Dependent = true, SetAccess = immutable)
        NScopes
    end
    
%     properties (Transient = true)
%         IsScopeVisibleWhenDisplayEnabled = true(1,0);  % logical row vector  
%           % A boolean array of length NScopes, indicates which scopes are
%           % visible when the Display subsystem is enabled.  If display
%           % subsystem is disabled, the scopes are all made invisible, but
%           % this stores who will be made immediately visible if the display
%           % system is reenabled.  Note that this is not persisted ---
%           % persistence of window visibility is all stored in the .usr
%           % file, and the WavesurferModel properties (of which Display is one)
%           % are all persisted in the .cfg file.  We want it to be clear to
%           % user where different kinds of things are stored, not confuse
%           % them by having some aspects of window visibilty stored in .usr,
%           % and some in .cfg.  The automatic hiding and restoring
%           % of windows when you check enable/disable display is just viewed
%           % as a convenience.
%     end
    
    properties (SetAccess = protected)
        Scopes = ws.ScopeModel.empty();
    end
    
    properties (Access = protected, Transient=true)
        XOffset_
    end

    properties (Access = protected)
        XSpan_ 
        UpdateRate_
    end
    
    properties (Access = protected, Transient=true)
        prvClearOnNextData = false
        prvCachedDisplayXSpan
    end
    
    events
        NScopesMayHaveChanged
    end
    
    events
        %EnablementMayHaveChanged
        DidSetScopeIsVisibleWhenDisplayEnabled
        DidSetIsXSpanSlavedToAcquistionDuration
        DidSetUpdateRate
        UpdateXSpan
    end

    methods
        function self = Display(parent)
            self.CanEnable=true;
            self.Parent=parent;  % the parent WavesurferModel object
            %self.Enabled=false;
            %self.addlistener('Enabled', 'PostSet', @self.enabledWasSet);
                % We now handle this by overriding the implementation of
                % set.Enabled
            self.XOffset_ = 0;  % s
            self.XSpan_ = 1;  % s
            self.UpdateRate_ = 10;  % Hz
            
            %self.registerDependentPropertiesForProperty('IsAutoRate', 'UpdateRate', @self.skip_set_update_rate);
            %self.registerDependentPropertiesForProperty('IsXSpanSlavedToAcquistionDuration', 'XSpan', @self.fireXSpanPostSetEvent);
            
            %parent.Acquisition.subscribeMe(self,'PostSet','Duration','fireXSpanPostSetEvent');  % TODO_ALT: Don't use events for this
        end
        
        function delete(self)
            self.removeScopes();
            self.Parent=[];
        end
        
        function value = get.UpdateRate(self)
            value = self.UpdateRate_;
        end
        
        function set.UpdateRate(self, newValue)
            if isfloat(newValue) && isscalar(newValue) && isnan(newValue) , % used by MOST to "fake" a set
                % do nothing
            else
                self.validatePropArg('UpdateRate', newValue);
                self.UpdateRate_ = newValue;
            end
            self.broadcast('DidSetUpdateRate');
        end
        
        function value = get.XSpan(self)
            import ws.utility.*
            if self.IsXSpanSlavedToAcquistionDuration ,
                value=1;  % s, fallback value
                wavesurferModel=self.Parent;
                if isempty(wavesurferModel) || ~isvalid(wavesurferModel) ,
                    return
                end
                acquisition=wavesurferModel.Acquisition;
                if isempty(acquisition) || ~isvalid(acquisition),
                    return
                end
                duration=acquisition.Duration;  % broadcaster is Acquisition subsystem
                value=fif(isfinite(duration),duration,1);
            else
                value = self.XSpan_;
            end
        end
        
        function set.XSpan(self, newValue)            
            if ~isnan(newValue) ,  % used by MOST to "fake" a set
                self.validatePropArg('XSpan', newValue);
                if ~self.IsXSpanSlavedToAcquistionDuration ,
                    self.XSpan_ = newValue;
                end
                for idx = 1:numel(self.Scopes) ,
                    self.Scopes(idx).XSpan = self.XSpan;  % N.B.: _not_ = self.XSpan_ !!
                end
            end    
            self.broadcast('UpdateXSpan');            
        end  % function
                
        function value = get.XOffset(self)
            value = self.XOffset_;
        end
        
        function set.XOffset(self, value)
            if isa(value,'ws.most.util.Nonvalue'), return, end            
            self.validatePropArg('XOffset', value);
            
            self.XOffset_ = value;
            
            for idx = 1:numel(self.Scopes)
                self.Scopes(idx).XOffset = value;
            end
        end
        
        function set.XAutoScroll(self, newValue)
            if isa(newValue,'ws.most.util.Nonvalue'), return, end            
            self.validatePropArg('XAutoScroll',newValue);
            self.XAutoScroll = newValue;
        end
        
        function value = get.IsXSpanSlavedToAcquistionDuration(self)
            value = self.IsXSpanSlavedToAcquistionDuration_;
        end
        
        function set.IsXSpanSlavedToAcquistionDuration(self,newValue)
            if ws.utility.isASettableValue(newValue) ,
                self.validatePropArg('IsXSpanSlavedToAcquistionDuration',newValue);
                self.IsXSpanSlavedToAcquistionDuration_=newValue;
                %self.XSpan=ws.most.util.Nonvalue.The;  % fake a set to XSpan to generate the appropriate events
                for idx = 1:numel(self.Scopes) ,
                    self.Scopes(idx).XSpan = self.XSpan;  % N.B.: _not_ = self.XSpan_ !!
                end
                self.broadcast('UpdateXSpan');                
            end
            self.broadcast('DidSetIsXSpanSlavedToAcquistionDuration');
        end
        
        function self=didSetAnalogChannelUnitsOrScales(self)
            scopes=self.Scopes;
            for i=1:length(scopes) ,
                scopes(i).didSetAnalogChannelUnitsOrScales();
            end
        end       
        
        function initializeScopes(self)
            % Set up the initial set of scope models, one per AI channel,
            % and one for all channels.
            activeChannelNames = self.Parent.Acquisition.ActiveChannelNames;
            for iChannel = 1:length(activeChannelNames) ,
                thisChannelName=activeChannelNames{iChannel};
                prototypeScopeTag=sprintf('Channel_%s', thisChannelName);
                scopeTag=self.tagFromString(prototypeScopeTag);  % this is a static method call
                scopeTitle=sprintf('Channel %s', thisChannelName);
                channelNames={thisChannelName};
                self.addScope(scopeTag, scopeTitle, channelNames);
            end
            %self.addScope('All_Channels','All Channels', activeChannelNames);            
        end        
        
        function addScope(self, scopeTag, scopeTitle, channelNames)
            narginchk(4, 4);
            
            if isempty(scopeTag)
                scopeTag = sprintf('Scope_%d', self.NScopes + 1);
            end
            if isempty(scopeTitle)
                scopeTitle = sprintf('Scope %d', self.NScopes + 1);
            end
            
            % Create the scope model
            scopeModel = ws.ScopeModel('Parent', self, ...
                                          'Tag', scopeTag, ...
                                          'Title', scopeTitle);
            
            % add the channels to the scope model                          
            nChannels=length(channelNames);
            for i = 1:nChannels
                channelName = channelNames{i};
                scopeModel.addChannel(channelName);
            end
            
            % Add the new scope to Scopes
            self.Scopes(end + 1) = scopeModel;
            %self.IsScopeVisibleWhenDisplayEnabled(end+1) = true;

            % We want to know if the visibility of the scope changes
            %scopeModel.addlistener('Visible', 'PostSet', @self.scopeVisibleDidChange);
            %scopeModel.subscribeMe(self,'PostSet','Visible','scopeVisibleDidChange');
            
            % Let anyone who cares know that the number of scopes has
            % changed
            self.broadcast('NScopesMayHaveChanged');
        end

%         function registerScopeController(self,scopeController)
%             %scopeController.subscribeMe(self,'ScopeVisibilitySet','','scopeVisibleDidChange');
%          end

        function removeScope(self, index)
            self.Scopes(index) = [];
            self.broadcast('NScopesMayHaveChanged');
        end
        
        function removeScopes(self)
            if ~isempty(self.Scopes) ,
                self.Scopes = ws.ScopeModel.empty();
                self.broadcast('NScopesMayHaveChanged');
            end
        end
        
        function willPerformExperiment(self, wavesurferObj, experimentMode)
%             if experimentMode == ws.ApplicationState.TestPulsing ,
%                 self.prvCachedDisplayXSpan = self.XSpan;
%                 self.XSpan = wavesurferObj.Ephys.MinTestPeriod;
%             else
            self.XOffset = 0;
            self.XSpan=self.XSpan;  % in case user has zoomed in on one or more scopes, want to reset now
%             end
            self.XAutoScroll= (experimentMode == ws.ApplicationState.AcquiringContinuously);
        end  % function
        
        function didPerformExperiment(self, wavesurferModel)
            self.didPerformOrAbortExperiment_(wavesurferModel);
        end
        
        function didAbortExperiment(self, wavesurferModel)
            self.didPerformOrAbortExperiment_(wavesurferModel);
        end
    end
    
    methods (Access=protected)
        function didPerformOrAbortExperiment_(self, wavesurferModel)
            if ~isempty(self.prvCachedDisplayXSpan)
                self.XSpan = self.prvCachedDisplayXSpan;
            end
            self.prvCachedDisplayXSpan = [];
        end        
    end
        
    methods    
        function willPerformTrial(self, ~)
            self.prvClearOnNextData = true;
        end
        
        function self=dataAvailable(self, state, t, scaledData, rawData) %#ok<INUSD>
            %T=zeros(4,1);
            %ticId=tic();            
            if self.prvClearOnNextData
                for sdx = 1:numel(self.Scopes)
                    self.Scopes(sdx).clearData();
                end
            end            
            self.prvClearOnNextData = false;
            %T(1)=toc(ticId);
            
            % update the x offset
            if self.XAutoScroll ,                
                scale=min(1,self.XSpan);
                tNudged=scale*ceil(100*t/scale)/100;  % Helps keep the axes aligned to tidy numbers
                xOffsetNudged=tNudged-self.XSpan;
                if xOffsetNudged>self.XOffset ,
                    self.XOffset_=xOffsetNudged;
                end
            end
            %T(2)=toc(ticId);

            % Feed the data to the scopes
            %T=zeros(3,1);
            inputChannelNames=self.Parent.Acquisition.ActiveChannelNames;
            for sdx = 1:numel(self.Scopes)
                % Figure out which channels go in this scope, and the
                % corresponding channel names
                % Although this looks like it might be slow, in practice it
                % takes negligible time compared to the call to
                % ScopeModel.addChannel() below.
                %TInner=zeros(1,2);
                %ticId2=tic();
                channelNamesForThisScope = cell(1,0);
                jInData = [];                
                for cdx = 1:length(inputChannelNames)
                    %channelName = sprintf('Acq_%d', inputChannelIDs(cdx));
                    channelName=inputChannelNames{cdx};
                    if any(strcmp(channelName, self.Scopes(sdx).ChannelNames)) ,
                        channelNamesForThisScope{end + 1} = channelName; %#ok<AGROW>
                        jInData(end + 1) = cdx; %#ok<AGROW>
                    end
                end
                %TInner(1)=toc(ticId2);
                
                % Add the data for the appropriate channels to this scope
                if ~isempty(jInData) ,
                    dataForThisScope=scaledData(:, jInData);
                    self.Scopes(sdx).addData(channelNamesForThisScope, dataForThisScope, self.Parent.Acquisition.SampleRate, self.XOffset_);
                end
                %TInner(2)=toc(ticId2);
            %fprintf('    In Display.dataAvailable() loop: %10.3f %10.3f\n',TInner);
            end
            %fprintf('In Display dataAvailable(): %20g %20g %20g\n',T);
            %T(3)=toc(ticId);
            
            %T(4)=toc(ticId);
            %fprintf('In Display.dataAvailable(): %10.3f %10.3f %10.3f %10.3f\n',T);
            %T=toc(ticId);
            %fprintf('Time in Display.dataAvailable(): %7.3f s\n',T);
        end
        
        function didSetAcquisitionDuration(self)
            % Called by the parent to notify of a change to the acquisition
            % duration
            
            % Want any listeners on XSpan set to get called
            if self.IsXSpanSlavedToAcquistionDuration ,
                for idx = 1:numel(self.Scopes) ,
                    self.Scopes(idx).XSpan = self.XSpan;  % N.B.: _not_ = self.XSpan_ !!
                end
                self.broadcast('UpdateXSpan');
            end    
            %self.XSpan = nan;
        end
        
        function out = get.NScopes(self)
            out = length(self.Scopes);
        end
                
        % Need to override the decodeProperties() method supplied by
        % ws.mixin.Coding() to get correct behavior when the number of
        % scopes changes.
        %function originalValues = decodeProperties(self, propSet)
        function decodeProperties(self, propSet)
            % Sets the properties in self to the values encoded in propSet.
            % Returns the _old_ property values from self in
            % originalValues.
            
            assert(isstruct(propSet));
            
            % Need to clear the existing scopes first
            self.removeScopes();
            
            % Now call the superclass method
            %originalValues=self.decodeProperties@ws.mixin.Coding(propSet);  % not _really_ the originalValues, but I don't think it matters...
            self.decodeProperties@ws.mixin.Coding(propSet);  % not _really_ the originalValues, but I don't think it matters...

            % Update the view
            self.broadcast('NScopesMayHaveChanged');
%             if ~isempty(self.Parent) ,
%                 self.Parent.nScopesMayHaveChanged();
%             end            
        end  % function
        
        function didSetScopeIsVisibleWhenDisplayEnabled(self)
            self.broadcast('DidSetScopeIsVisibleWhenDisplayEnabled');
        end
    end  % pulic methods block
    
    methods (Access = protected)
%         function defineDefaultPropertyAttributes(self)
%             defineDefaultPropertyAttributes@ws.system.Subsystem(self);
%             self.setPropertyAttributeFeatures('UpdateRate', 'Classes', 'numeric', 'Attributes', {'scalar', 'positive', 'finite'});
%             self.setPropertyAttributeFeatures('XOffset', 'Attributes', {'scalar', 'finite'});
%             self.setPropertyAttributeFeatures('XSpan', 'Attributes', {'scalar', 'positive', 'finite'});
%             %self.setPropertyAttributeFeatures('IsAutoRate', 'Classes', {'logical'}, 'Attributes', {'scalar'});
%             self.setPropertyAttributeFeatures('IsXSpanSlavedToAcquistionDuration', 'Classes', {'logical'}, 'Attributes', {'scalar'});
%             self.setPropertyAttributeFeatures('XAutoScroll', 'Classes', {'logical'}, 'Attributes', {'scalar'});
%         end
        
%         function defineDefaultPropertyTags(self)
%             defineDefaultPropertyTags@ws.system.Subsystem(self);            
%             %self.setPropertyTags('Enabled', 'IncludeInFileTypes', {'cfg'}, 'ExcludeFromFileTypes', {'usr'});
%             self.setPropertyTags('UpdateRate_', 'IncludeInFileTypes', {'cfg'}, 'ExcludeFromFileTypes', {'usr'});
%             self.setPropertyTags('Scopes', 'IncludeInFileTypes', {'cfg'}, 'ExcludeFromFileTypes', {'usr'});
%             self.setPropertyTags('XAutoScroll', 'IncludeInFileTypes', {'cfg'}, 'ExcludeFromFileTypes', {'usr'});
%             self.setPropertyTags('XSpan_', 'IncludeInFileTypes', {'cfg'}, 'ExcludeFromFileTypes', {'usr'});
%             self.setPropertyTags('IsXSpanSlavedToAcquistionDuration_', 'IncludeInFileTypes', {'cfg'}, 'ExcludeFromFileTypes', {'usr'});
%         end
        
%         function skip_set_update_rate(self, varargin)
%             % Need to trigger a property set, but don't want to change the actual protected
%             % value.
%             original = self.UpdateRate;
%             self.UpdateRate = 1;
%             self.UpdateRate = original;
%         end
        
%         function setEnabledImplementation_(self, value)
%             % This is called when Enabled is set in Subsystem, and we
%             % override it here to provide Display-specific behavior.
%             self.setEnabledImplementation_@ws.system.Subsystem(value);  % call superclass method
%             
%             self.notify('EnablementMayHaveChanged');
%         end  % function
        
        % Allows access to protected and protected variables from ws.mixin.Coding.
        function out = getPropertyValue(self, name)            
            out = self.(name);
        end
        
        % Allows access to protected and protected variables from ws.mixin.Coding.
        function setPropertyValue(self, name, value)
            if nargin < 3
                value = [];
            end
            
            self.(name) = value;
            if isequal(name,'Scopes') ,
                % Make sure they back-reference to the right Display (i.e. self)
                for i=1:length(self.Scopes)
                    setPropertyValue(self.Scopes(i),'Parent',self);
                end                
            end                
        end  % function
        
    end  % protected methods
    
    methods
%         function set.IsScopeVisibleWhenDisplayEnabled(self,newValue)
%             self.IsScopeVisibleWhenDisplayEnabled=newValue;
%             %self.notify('ScopeVisibilitySet');
%         end
        
%         function scopeVisibleDidChange(self,broadcaster,eventName,propertyName,source,event) %#ok<INUSD>
%             % If the user toggles the scope visibility via the menu or other mechanism when
%             % the display subsystem is disabled, update the cached visibility information so
%             % that when the display subsystem is re-enabled it is not setting visibility
%             % based on stale information.
%             if ~self.Enabled && ~self.IsChangingScopeVisibility ,
%                 self.IsScopeVisibleWhenDisplayEnabled(self.Scopes == broadcaster) = broadcaster.Visible;
%             end
%             self.notify('ScopeVisibilitySet');
%         end
        
%         function enabledWasSet(self, ~, ~)
%             % This is a "receiver" method, intended to be called by a
%             % listener when an event happens.  In this case, when a PostSet
%             % event happens on the Enabled property.
%             
%             if self.Enabled
%                 if ~isempty(self.Scopes) && numel(self.Scopes) == numel(self.IsScopeVisibleWhenDisplayEnabled)
%                     for idx = 1:numel(self.Scopes)
%                         self.Scopes(idx).Visible = self.IsScopeVisibleWhenDisplayEnabled(idx);
%                     end
%                 end                
%             else
%                 self.IsScopeVisibleWhenDisplayEnabled = false(0, 1);
%                 self.IsChangingScopeVisibility = true;
%                 for idx = 1:numel(self.Scopes)
%                     self.IsScopeVisibleWhenDisplayEnabled(idx) = self.Scopes(idx).Visible;
%                     self.Scopes(idx).Visible = false;
%                 end
%                 self.IsChangingScopeVisibility = false;
%             end
%         end
    end
    
    methods (Access=public)
%         function resetProtocol(self)  % has to be public so WavesurferModel can call it
%             % Clears all aspects of the current protocol (i.e. the stuff
%             % that gets saved/loaded to/from the config file.  Idea here is
%             % to return the protocol properties stored in the model to a
%             % blank slate, so that we're sure no aspects of the old
%             % protocol get carried over when loading a new .cfg file.
%             
%             self.Enabled=true;
%             self.IsAutoRate=1;
%             self.IsXSpanSlavedToAcquistionDuration=1;
%             self.Scopes=ws.ScopeModel.empty();  
%             self.UpdateRate=10;  % Hz
%         end  % function
    end % methods
    
    methods (Static=true)
        function tag=tagFromString(str)
            % Transform an arbitrary ASCII string into a tag, which must be
            % a valid Matlab identifier            
            if isempty(str) ,
                tag=str;  % maybe should throw error, but they'll find out soon enough...
                return
            end
            
            % Replace illegal chars with underscores
            isAlphanumeric=isstrprop(str,'alphanum');
            isUnderscore=(str=='_');
            isIllegal= ~isAlphanumeric & ~isUnderscore;
            temp=str;
            temp(isIllegal)='_';
            
            % If first char is not alphabetic, replace with 'a'
            isFirstCharAlphabetic=isstrprop(temp(1),'alpha');
            if ~isFirstCharAlphabetic, 
                temp(1)='a';
            end
            
            % Return the tag
            tag=temp;
        end  % function
    end
    
    properties (Hidden, SetAccess=protected)
        mdlPropAttributes = ws.system.Display.propertyAttributes();
        
        mdlHeaderExcludeProps = {};
    end
    
    methods (Static)
        function s = propertyAttributes()
            s = ws.system.Subsystem.propertyAttributes();

            s.UpdateRate = struct('Attributes',{{'positive' 'finite' 'scalar'}});
            s.XOffset = struct('Attributes',{{'finite' 'scalar'}});
            s.XSpan = struct('Attributes',{{'positive' 'finite' 'scalar'}}, ...
                             'DependsOn','IsXSpanSlavedToAcquistionDuration');              
            s.IsXSpanSlavedToAcquistionDuration = struct('Classes','binarylogical');
            s.XAutoScroll = struct('Classes','binarylogical');            
        end  % function
    end  % class methods block
    
end
