classdef AnalogInputTask < handle
    %   The AnalogInputTask provides a high level interface around the dabs DAQmx
    %   classes for finite sample acquisition using channels from a single board.
    %
    %   AnalogInputTask provides a configurable active channels property,
    %   registration for sample and done events using standard addlistener() calls,
    %   a trigger delegate for optionally providing on-demand trigger settings, and
    %   time-based acquisition duration and sample available events (i.e. sample
    %   rate independent values)
    %
    %   It also provides on-demand registration of DAQmx callbacks to prevent
    %   circular references and failure to delete objects and classes under
    %   non-error conditions.
    %
    %   Note that management of the internal DAQmx tasks is the responsibility of
    %   the AnalogInputTask class.  For example, the class does not provide a
    %   stop() method.  For operations that complete normally, required method calls
    %   on the underlying task, such as stop(), are handled automically.
    %   AnalogInputTask does provide an abort() method to interrupt a running
    %   task.
    
%     properties (Transient = true, Dependent = true, SetAccess = immutable)
%         AreCallbacksRegistered
%     end
    
    properties (Transient = true, Access = protected)
        DabsDaqTask_ = [];
    end
    
    properties (Access = protected)
        RegistrationCount_ = 0;  
            % Roughly, the number of times registerCallbacks() has been
            % called, minus the number of times unregisterCallbacks() has
            % been called Used to make sure the callbacks are only
            % registered once even if registerCallbacks() is called
            % multiple times in succession.
    end
    
    properties (Dependent = true, SetAccess = immutable)
        % These are all set in the constructor, and not changed
        DeviceName
        AvailableChannels  % Zero-based AI channel IDs, all of them
        TaskName
        ChannelNames
    end

    properties (Dependent = true, SetAccess = immutable)
        % These are not directly settable
        ExpectedScanCount
        NScansPerDataAvailableCallback
    end
    
    properties (Dependent = true)
        ActiveChannels  % Zero-based AI channel Ids, all of them
        SampleRate      % Hz
        AcquisitionDuration  % Seconds
        DurationPerDataAvailableCallback  % Seconds
        ClockTiming 
        TriggerDelegate  % empty or a trigger Destination or a trigger Source
    end
    
    properties (Access = protected)
        SampleRate_ = 20000
        AvailableChannels_ = zeros(1,0)  % Zero-based AI channel IDs, all of them
        ActiveChannels_ = zeros(1,0)
        AcquisitionDuration_ = 1     % Seconds
        DurationPerDataAvailableCallback_ = 0.1  % Seconds
        ClockTiming_ = ws.ni.SampleClockTiming.FiniteSamples
        TriggerDelegate_ = []  % empty or a trigger Destination or a trigger Source
    end
    
    events
        AcquisitionComplete
        SamplesAvailable
    end
    
    methods
        function delete(self)
            %self.unregisterCallbacks();
            if ~isempty(self.DabsDaqTask_) && self.DabsDaqTask_.isvalid() ,
                delete(self.DabsDaqTask_);  % have to explicitly delete, b/c ws.dabs.ni.daqmx.System has refs to, I guess
            end
            self.DabsDaqTask_=[];
        end
        
%         function out = get.AreCallbacksRegistered(self)
%             out = self.RegistrationCount_ > 0;
%         end
                
        function start(self)
%             if isa(self,'ws.ni.FiniteAnalogOutputTask') ,
%                 %fprintf('About to start FiniteAnalogOutputTask.\n');
%                 %self
%                 %dbstack
%             end               
            if ~isempty(self.DabsDaqTask_)
                %self.getReadyGetSet();
                self.DabsDaqTask_.start();
            end
        end
                
        function abort(self)
%             if isa(self,'ws.ni.AnalogInputTask') ,
%                 fprintf('AnalogInputTask::abort()\n');
%             end
%             if isa(self,'ws.ni.FiniteAnalogOutputTask') ,
%                 fprintf('FiniteAnalogOutputTask::abort()\n');
%             end
            if ~isempty(self.DabsDaqTask_)
                self.DabsDaqTask_.abort();
            end
        end
        
        function stop(self)
%             if isa(self,'ws.ni.AnalogInputTask') ,
%                 fprintf('AnalogInputTask::stop()\n');
%             end
%             if isa(self,'ws.ni.FiniteAnalogOutputTask') ,
%                 fprintf('FiniteAnalogOutputTask::stop()\n');
%             end
            if ~isempty(self.DabsDaqTask_) && ~self.DabsDaqTask_.isTaskDoneQuiet()
                self.DabsDaqTask_.stop();
            end
        end
        
        function registerCallbacks(self)
%             if isa(self,'ws.ni.AnalogInputTask') ,
%                 fprintf('Task::registerCallbacks()\n');
%             end
            % Public method that causes the every-n-samples callbacks (and
            % others) to be set appropriately for the
            % acquisition/stimulation task.  This calls a subclass-specific
            % implementation method.  Typically called just before starting
            % the task. Also includes logic to make sure the implementation
            % method only gets called once, even if this method is called
            % multiple times in succession.
            if self.RegistrationCount_ == 0
                self.registerCallbacksImplementation();
            end
            self.RegistrationCount_ = self.RegistrationCount_ + 1;
        end
        
        function unregisterCallbacks(self)
            % Public method that causes the every-n-samples callbacks (and
            % others) to be cleared.  This calls a subclass-specific
            % implementation method.  Typically called just after the task
            % ends.  Also includes logic to make sure the implementation
            % method only gets called once, even if this method is called
            % multiple times in succession.
            %
            % Be cautious with this method.  If the DAQmx callbacks are the last MATLAB
            % variables with references to this object, the object may become invalid after
            % these sets.  Call this method last in any method where it is used.

%             if isa(self,'ws.ni.AnalogInputTask') ,
%                 fprintf('Task::unregisterCallbacks()\n');
%             end

            %assert(self.RegistrationCount_ > 0, 'Unbalanced registration calls.  Object is in an unknown state.');
            
            if (self.RegistrationCount_>0) ,            
                self.RegistrationCount_ = self.RegistrationCount_ - 1;            
                if self.RegistrationCount_ == 0
                    self.unregisterCallbacksImplementation();
                end
            end
        end
        
        function debug(self) %#ok<MANU>
            keyboard
        end        
    end
    
    methods
        function self = AnalogInputTask(deviceName, channelIndices, taskName, channelNames)
            nChannels=length(channelIndices);
            
            %self.AvailableChannels = channelIndices;
            if isnumeric(channelIndices) && isrow(channelIndices) && all(channelIndices==round(channelIndices)) && all(channelIndices>=0) ,
                self.AvailableChannels_ = channelIndices;
            else
                error('most:Model:invalidPropVal', ...
                      'AvailableChannels must be empty or a vector of nonnegative integers.');       
            end

%             % Convert deviceNames from string to cell array of strings if
%             % needed
%             if ischar(deviceName) ,
%                 deviceName=repmat({deviceName},[1 nChannels]);
%             end
            
            % Check that deviceName is kosher
            if ischar(deviceName) && (isempty(deviceName) || isrow(deviceName)) ,
                % do nothing
            else
                error('AnalogInputTask:deviceNameBad' , ...
                      'deviceName is wrong type or not a row vector.');
            end
            
            % Use default channel names, if needed
            if exist('channelNames','var') ,
                % Check that channelNames is kosher
                if  iscellstr(channelNames) && length(channelNames)==nChannels ,
                    % do nothing
                else
                    error('AnalogInputTask:channelNamesBad' , ...
                          'channelNames is wrong type or wrong length.');
                end                
            else
                % Use default channelNames
                channelNames = cell(1,nChannels) ;
                for i=1:nChannels ,
                    channelNames{i} = sprintf('%s/ai%s',deviceName,channelIndices(i));
                end
            end
            
            % Create the task, channels
            if nChannels==0 ,
                self.DabsDaqTask_ = [];
            else
                self.DabsDaqTask_ = ws.dabs.ni.daqmx.Task(taskName);
                
                % create the channels
                self.DabsDaqTask_.createAIVoltageChan(deviceName, channelIndices, channelNames);
                
                % Set the timing mode
                self.DabsDaqTask_.cfgSampClkTiming(self.SampleRate_, 'DAQmx_Val_FiniteSamps');  % do we need this?  This stuff is set in setup()...
            end
            
            self.ActiveChannels = self.AvailableChannels;            
        end  % function
        
        % Shouldn't there be a delete() method to at least free up
        % DabsDaqTask_?  Don't need one, that's handled by the superclass.
        
        function value = get.AvailableChannels(self)
            value = self.AvailableChannels_;
        end  % function
        
        function value = get.ActiveChannels(self)
            value = self.ActiveChannels_;
        end  % function
        
        function set.ActiveChannels(self, value)
            if ~( isempty(value) || ( isnumeric(value) && isvector(value) && all(value==round(value)) ) ) ,
                error('most:Model:invalidPropVal', ...
                      'ActiveChannels must be empty or a vector of integers.');       
            end
            
            availableActive = intersect(self.AvailableChannels, value);
            
            if numel(value) ~= numel(availableActive)
                ws.most.mimics.warning('Wavesurfer:Aqcuisition:invalidChannels', 'Not all requested channels are available.\n');
            end
            
            if ~isempty(self.DabsDaqTask_)
                channelsToRead = '';
                
                for cdx = availableActive
                    idx = find(self.AvailableChannels == cdx, 1);
                    channelsToRead = sprintf('%s%s, ', channelsToRead, self.ChannelNames{idx});
                end
                
                channelsToRead = channelsToRead(1:end-2);
                
                set(self.DabsDaqTask_, 'readChannelsToRead', channelsToRead);
            end
            
            self.ActiveChannels_ = availableActive;
        end  % function
        
%         function value = get.ActualAcquisitionDuration(self)
%             value = (self.ExpectedScanCount)/self.SampleRate_;
%         end  % function
        
%         function set.AvailableChannels(self, value)
%             if isnumeric(value) && isrow(value) && all(value==round(value)) ,
%                 self.AvailableChannels = value;
%             else
%                 error('most:Model:invalidPropVal', ...
%                       'AvailableChannels must be empty or a vector of integers.');       
%             end
%         end  % function
        
        function out = get.ChannelNames(self)
            if ~isempty(self.DabsDaqTask_)
                c = self.DabsDaqTask_.channels;
                out = {c.chanName};
            else
                out = {};
            end
        end  % function
        
        function out = get.DeviceName(self)
            if ~isempty(self.DabsDaqTask_)
                out = self.DabsDaqTask_.deviceNames{1};
            else
                out = '';
            end
        end  % function
        
        function value = get.ExpectedScanCount(self)
            value = round(self.AcquisitionDuration * self.SampleRate_);
        end  % function
        
        function value = get.SampleRate(self)
            value = self.SampleRate_;
        end  % function
        
        function set.SampleRate(self,value)
            if ~( isnumeric(value) && isscalar(value) && (value==round(value)) && value>0 )  ,
                error('most:Model:invalidPropVal', ...
                      'SampleRate must be a positive integer');       
            end            
            
            if ~isempty(self.DabsDaqTask_)
                oldSampClkRate = self.DabsDaqTask_.sampClkRate;
                self.DabsDaqTask_.sampClkRate = value;
                try
                    self.DabsDaqTask_.control('DAQmx_Val_Task_Verify');
                catch me
                    self.DabsDaqTask_.sampClkRate = oldSampClkRate;
                    % This will put the sampleRate property in sync with the hardware, but it will
                    % be an odd artifact that the sampleRate value did not change to the reqested,
                    % but to something else.  This can be fixed by doing a verify when first setting
                    % the clock in ziniPrepareAcquisitionDAQ and setting the sampleRate property to
                    % the clock value if it fails.  Since it is called at construction, the user
                    % will never see the original, invalid sampleRate property value.
                    self.SampleRate_ = oldSampClkRate;
                    error('Invalid sample rate value');
                end
            end
            
            self.SampleRate_ = value;
        end  % function
        
        function value = get.NScansPerDataAvailableCallback(self)
            value = round(self.DurationPerDataAvailableCallback * self.SampleRate);
              % The sample rate is technically a scan rate, so this is
              % correct.
        end  % function
        
        function set.DurationPerDataAvailableCallback(self, value)
            if ~( isnumeric(value) && isscalar(value) && value>=0 )  ,
                error('most:Model:invalidPropVal', ...
                      'DurationPerDataAvailableCallback must be a nonnegative scalar');       
            end            
            self.DurationPerDataAvailableCallback_ = value;
        end  % function

        function value = get.DurationPerDataAvailableCallback(self)
            value = min(self.AcquisitionDuration_, self.DurationPerDataAvailableCallback_);
        end  % function
        
        function out = get.TaskName(self)
            if ~isempty(self.DabsDaqTask_)
                out = self.DabsDaqTask_.taskName;
            else
                out = '';
            end
        end  % function
        
        function set.AcquisitionDuration(self, value)
            if ~( isnumeric(value) && isscalar(value) && value>0 )  ,
                error('most:Model:invalidPropVal', ...
                      'AcquisitionDuration must be a positive scalar');       
            end            
            self.AcquisitionDuration_ = value;
        end  % function
        
        function value = get.AcquisitionDuration(self)
            value = self.AcquisitionDuration_ ;
        end  % function
        
        function set.TriggerDelegate(self, value)
            if ~( isequal(value,[]) || (isa(value,'ws.ni.HasPFIIDAndEdge') && isscalar(value)) )  ,
                error('most:Model:invalidPropVal', ...
                      'TriggerDelegate must be empty or a scalar ws.ni.HasPFIIDAndEdge');       
            end            
            self.TriggerDelegate_ = value;
        end  % function
        
        function value = get.TriggerDelegate(self)
            value = self.TriggerDelegate_ ;
        end  % function                
        
        function set.ClockTiming(self,value)
            if ~( isscalar(value) && isa(value,'ws.ni.SampleClockTiming') ) ,
                error('most:Model:invalidPropVal', ...
                      'ClockTiming must be a scalar ws.ni.SampleClockTiming');       
            end            
            self.ClockTiming_ = value;
        end  % function           
        
        function value = get.ClockTiming(self)
            value = self.ClockTiming_ ;
        end  % function                
        
        function setup(self)
            % called before the first call to start()
            %fprintf('AnalogInputTask::setup()\n');
            switch self.ClockTiming ,
                case ws.ni.SampleClockTiming.FiniteSamples
                    self.DabsDaqTask_.cfgSampClkTiming(self.SampleRate_, 'DAQmx_Val_FiniteSamps', self.ExpectedScanCount);
                case ws.ni.SampleClockTiming.ContinuousSamples
                    if isinf(self.ExpectedScanCount)
                        bufferSize = self.SampleRate_; % Default to 1 second of data as the buffer.
                    else
                        bufferSize = self.ExpectedScanCount;
                    end
                    self.DabsDaqTask_.cfgSampClkTiming(self.SampleRate_, 'DAQmx_Val_ContSamps', 2 * bufferSize);
                otherwise
                    assert(false, 'finiteacquisition:unknownclocktiming', 'Unexpected clock timing mode.');
            end

            if ~isempty(self.TriggerDelegate)
                self.DabsDaqTask_.cfgDigEdgeStartTrig(sprintf('PFI%d', self.TriggerDelegate.PFIID), self.TriggerDelegate.Edge.daqmxName());
            else
                self.DabsDaqTask_.disableStartTrig();  % This means the daqmx.Task will not wait for any trigger after getting the start() message, I think
            end                
        end  % function

        function reset(self) %#ok<MANU>
            % called before the second and subsequent calls to start()
            %fprintf('AnalogInputTask::reset()\n');                        
            % Don't have to do anything to reset a finite input analog task
        end  % function
    end
    
    methods (Access = protected)
%         function defineDefaultPropertyAttributes(self)
%             defineDefaultPropertyAttributes@ws.ni.AnalogTask(self);
%             self.setPropertyAttributeFeatures('ActiveChannels', 'Classes', 'numeric', 'Attributes', {'vector', 'integer'}, 'AllowEmpty', true);
%             self.setPropertyAttributeFeatures('SampleRate', 'Attributes', {'positive', 'integer', 'scalar'});
%             self.setPropertyAttributeFeatures('AcquisitionDuration', 'Attributes', {'positive', 'scalar'});            
%             self.setPropertyAttributeFeatures('DurationPerDataAvailableCallback', 'Attributes', {'nonnegative', 'scalar'});
%             self.setPropertyAttributeFeatures('TriggerDelegate', 'Classes', 'ws.ni.HasPFIIDAndEdge', 'Attributes', 'scalar', 'AllowEmpty', true);          
%             self.setPropertyAttributeFeatures('AvailableChannels', 'Classes', 'numeric', 'Attributes', {'vector', 'integer'}, 'AllowEmpty', true);
%         end  % function
        
        function registerCallbacksImplementation(self)
            if self.DurationPerDataAvailableCallback > 0 ,
                self.DabsDaqTask_.registerEveryNSamplesEvent(@self.nSamplesAvailable_, self.NScansPerDataAvailableCallback);
                  % This registers the callback function that is called
                  % when self.NScansPerDataAvailableCallback samples are
                  % available
            end
            
            self.DabsDaqTask_.doneEventCallbacks = {@self.taskDone_};
        end  % function
        
        function unregisterCallbacksImplementation(self)
            self.DabsDaqTask_.registerEveryNSamplesEvent([]);
            self.DabsDaqTask_.doneEventCallbacks = {};
        end  % function
        
    end  % protected methods block
    
    methods (Access = protected)
        function nSamplesAvailable_(self, source, event) %#ok<INUSD>
            %fprintf('AnalogInputTask::nSamplesAvailable_()\n');
            rawData = source.readAnalogData(self.NScansPerDataAvailableCallback,'native') ;  % rawData is int16            
            eventData = ws.ni.SamplesAvailableEventData(rawData) ;
            self.notify('SamplesAvailable', eventData);
        end  % function
        
        function taskDone_(self, source, event) %#ok<INUSD>
            %fprintf('AnalogInputTask::taskDone_()\n');
            % For a successful capture, this class is responsible for stopping the task when
            % it is done.  For external clients to interrupt a running task, use the abort()
            % method on the Acquisition object.
            self.DabsDaqTask_.abort();
            
            % Fire the event before unregistering the callback functions.  At the end of a
            % script the DAQmx callbacks may be the only references preventing the object
            % from deleting before the events are sent/complete.
            self.notify('AcquisitionComplete');
        end  % function
        
%         function ziniPrepareAcquisitionDAQ(self, device, availableChannels, taskName, channelNames)
%             self.AvailableChannels = availableChannels;
%             
%             if nargin < 5
%                 channelNames = {};
%             end
%             
%             if ~isempty(device) && ~isempty(self.AvailableChannels)
%                 self.DabsDaqTask_ = ws.dabs.ni.daqmx.Task(taskName);
%                 self.DabsDaqTask_.createAIVoltageChan(device, self.AvailableChannels, channelNames);
%                 self.DabsDaqTask_.cfgSampClkTiming(self.SampleRate_, 'DAQmx_Val_FiniteSamps');
%                 
%                 % Use hardware retriggering, if possible.  For boards that do support this
%                 % property, a start trigger must be defined in order to query the value without
%                 % error.
%                 self.DabsDaqTask_.cfgDigEdgeStartTrig('PFI1', ws.ni.TriggerEdge.Rising.daqmxName());
%                 self.isRetriggerable = ~isempty(get(self.DabsDaqTask_, 'startTrigRetriggerable'));
%                 self.DabsDaqTask_.disableStartTrig();
%             else
%                 self.DabsDaqTask_ = [];
%             end
%             
%             self.ActiveChannels = self.AvailableChannels;
%         end
    end  % protected methods block
end
