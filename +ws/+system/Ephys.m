classdef Ephys < ws.system.Subsystem
    %Ephys  Wavesurfer subsystem responsible for most Ephys-related behaviors.
    %
    %    The Ephys subsystem manages electrode configuration and settings
    %    communication for Wavesurfer electrophysiology runs.
    
    %%
    properties (Access = protected)
        ElectrodeManager_
        TestPulser_
    end
    
    %%
    properties (Dependent=true, SetAccess=immutable)
        ElectrodeManager  % provides public access to ElectrodeManager_
        TestPulser  % provides public access to TestPulser_
    end    
      
    %%
%     events
%         MayHaveChanged
%     end

    %%
    methods
        %%
        function self = Ephys(parent)
            self@ws.system.Subsystem(parent);
            self.IsEnabled=true;            
            self.ElectrodeManager_=ws.ElectrodeManager(self);
            self.TestPulser_=ws.TestPulser(self);
        end
        
        %%
        function delete(self)
            %self.Parent=[];  % eliminate reference to host WavesurferModel object
            %delete(self.TestPulser_);  % do i need this?  No.
            %delete(self.ElectrodeManager_);  % do i need this?  No.
            self.TestPulser_ = [] ;
            self.ElectrodeManager_ = [] ;
        end
        
        %%
        function out = get.TestPulser(self)
            out=self.TestPulser_;
        end
        
        %%
        function out = get.ElectrodeManager(self)
            out=self.ElectrodeManager_;
        end
        
        %%
%         function initializeUsingMDF(self, mdfData)
%             % This method is the public interface to establishing hardware other
%             % configuration information defined in the machine data file.  It is called from
%             % WavesurferModel.initializeFromMDF() when it is first loaded with a machine data file.
%             
%             self.ElectrodeManager_=ws.ElectrodeManager('Parent',self);            
%             for idx = 1:1000 ,
%                 electrodeId = sprintf('electrode%d', idx);
%                 
%                 if ~isfield(mdfData, [electrodeId 'Type'])
%                     break;
%                 end
%                 
%                 if isempty(mdfData.([electrodeId 'Type']))
%                     continue;
%                 end
%                 
%                 % If you have p-v pairs defined in mdf entries such as 'electrode1Properties',
%                 % they get applied here in the constructor for the device-specific
%                 % electrode class.
%                 electrodeType=mdfData.([electrodeId 'Type']);
%                 electrodeClassName=[electrodeType 'Electrode'];
%                 electrodeFullClassName=['ws.ephys.vendor.' electrodeClassName];
%                 electrode = feval(electrodeFullClassName, self, mdfData.([electrodeId 'Properties']){:});
%                 
%                 % Sort out the output and input channel names.
%                 electrode.VoltageCommandChannelName = mdfData.([electrodeId 'VoltageCommandChannelName']);
%                 electrode.CurrentCommandChannelName = mdfData.([electrodeId 'CurrentCommandChannelName']);
%                 electrode.VoltageMonitorChannelName = mdfData.([electrodeId 'VoltageMonitorChannelName']);
%                 electrode.CurrentMonitorChannelName = mdfData.([electrodeId 'CurrentMonitorChannelName']);
%                 
%                 % DAQ channels related to configuration reading/writing, where applicable.
%                 electrode.setConfigurationChannels(mdfData.([electrodeId 'ConfigChannelNames']));
%                 
%                 % If the electrode name was not set from a PV pair in the mdf give it a
%                 % reasonable default.
%                 if isempty(electrode.Name)
%                     electrode.Name = sprintf('Electrode %d', numel(self.Electrodes_) + 1);
%                 end
%                 
%                 self.ElectrodeManager_.addElectrode(electrode)
%                 %self.Electrodes{end + 1} = electrode;
%             end
%             
%             self.TestPulser_=ws.TestPulser('Parent',self);
%         end
        
%         function acquireHardwareResources(self) %#ok<MANU>
%             % Nothing to do here, maybe
%         end  % function
% 
%         function releaseHardwareResources(self) %#ok<MANU>
%             % Nothing to do here, maybe
%         end

        %%
        function electrodeMayHaveChanged(self,electrode,propertyName)
            % Called by the ElectrodeManager to notify that the electrode
            % may have changed.
            % Currently, tells TestPulser about the change, and the parent
            % WavesurferModel.
            if ~isempty(self.TestPulser_)
                self.TestPulser_.electrodeMayHaveChanged(electrode,propertyName);
            end
            if ~isempty(self.Parent)
                self.Parent.electrodeMayHaveChanged(electrode,propertyName);
            end
        end

        %%
        function electrodeWasAdded(self,electrode)
            % Called by the ElectrodeManager when an electrode is added.
            % Currently, informs the TestPulser of the change.
            if ~isempty(self.TestPulser_)
                self.TestPulser_.electrodeWasAdded(electrode);
            end
        end

        %%
        function electrodesRemoved(self)
            % Called by the ElectrodeManager when one or more electrodes
            % are removed.
            % Currently, informs the TestPulser of the change.
            if ~isempty(self.TestPulser_)
                self.TestPulser_.electrodesRemoved();
            end
            if ~isempty(self.Parent)
                self.Parent.electrodesRemoved();
            end
        end

        %% 
        function self=didSetAnalogChannelUnitsOrScales(self)
            testPulser=self.TestPulser;
            if ~isempty(testPulser) ,
                testPulser.didSetAnalogChannelUnitsOrScales();
            end            
        end       
        
        %%
        function isElectrodeMarkedForTestPulseMayHaveChanged(self)
            if ~isempty(self.TestPulser_)
                self.TestPulser_.isElectrodeMarkedForTestPulseMayHaveChanged();
            end
        end
                
        %%
        function startingRun(self)
            % Update all the gains and modes that are associated with smart
            % electrodes
            self.ElectrodeManager_.updateSmartElectrodeGainsAndModes();
        end
        
        %%
        function completingRun(self) %#ok<MANU>
        end
        
        %%
        function abortingRun(self) %#ok<MANU>
        end
        
        function didSetAcquisitionSampleRate(self,newValue)
            testPulser = self.TestPulser ;
            if ~isempty(testPulser) ,
                testPulser.didSetAcquisitionSampleRate(newValue) ;
            end
        end        
    end  % methods block
    
    methods         
        function propNames = listPropertiesForHeader(self)
            propNamesRaw = listPropertiesForHeader@ws.Model(self) ;            
            % delete some property names that are defined in subclasses
            % that don't need to go into the header file
            propNames=setdiff(propNamesRaw, ...
                              {'TestPulser'}) ;
        end  % function 
    end  % public methods block    
    
    %%
    methods (Access = protected)
%         %%
%         function defineDefaultPropertyAttributes(self)
%             defineDefaultPropertyAttributes@ws.system.Subsystem(self);
%         end
        
%         %%
%         function defineDefaultPropertyTags_(self)
%             defineDefaultPropertyTags_@ws.system.Subsystem(self);                        
%             self.setPropertyTags('TestPulser', 'ExcludeFromFileTypes', {'header'});
%         end
        
        %% Allows access to protected and protected variables from ws.mixin.Coding.
        function out = getPropertyValue_(self, name)
            out = self.(name);
        end
        
        %% Allows access to protected and protected variables from ws.mixin.Coding.
        function setPropertyValue_(self, name, value)
            self.(name) = value;
        end
    end  % protected methods block
    
    %%
    methods (Access=public)
%         %%
%         function resetProtocol(self)  % has to be public so WavesurferModel can call it
%             % Clears all aspects of the current protocol (i.e. the stuff
%             % that gets saved/loaded to/from the config file.  Idea here is
%             % to return the protocol properties stored in the model to a
%             % blank slate, so that we're sure no aspects of the old
%             % protocol get carried over when loading a new .cfg file.            
% %             self.IsEnabled=false;  % this doesn't seem right...
% %             self.TestPulser_=ws.TestPulser('Parent',self);
% %             self.ElectrodeManager_.resetProtocol();
%         end  % function
    end % methods
    
%     properties (Hidden, SetAccess=protected)
%         mdlPropAttributes = struct() ;
%         mdlHeaderExcludeProps = {};
%     end
    
%     methods (Static)
%         function s = propertyAttributes()
%             s = ws.system.Subsystem.propertyAttributes();
%         end  % function
%     end  % class methods block
    
    methods
        function mimic(self, other)
            % Cause self to resemble other.
            
            % Get the list of property names for this file type
            propertyNames = self.listPropertiesForPersistence();
            
            % Set each property to the corresponding one
            % all the "configurable" props in this class hold scalar
            % ws.Model objects, so this is simple
            for i = 1:length(propertyNames) ,
                thisPropertyName=propertyNames{i};
                if any(strcmp(thisPropertyName,{'ElectrodeManager_', 'TestPulser_'})) ,
                    source = other.(thisPropertyName) ;  % source as in source vs target, not as in source vs destination
                    target = self.(thisPropertyName) ;
                    target.mimic(source);  % all the props in this class hold scalar ws.Model objects
                else
                    if isprop(other,thisPropertyName)
                        source = other.getPropertyValue_(thisPropertyName) ;
                        self.setPropertyValue_(thisPropertyName, source) ;
                    end                    
                end
            end
        end  % function
    end  % public methods block

end  % classdef
