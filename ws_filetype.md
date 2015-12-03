Notes on ws filetype:


structure

````

|-- header
|    |-- AbsoluteProtocolFileName
|    |-- AbsoluteUserSettingsFileName
|    |-- Acquisition
|    |    |-- ActiveChannelNames
|    |    |-- AnalogChannelIDs
|    |    |-- AnalogChannelNames
|    |    |-- AnalogChannelScales
|    |    |-- AnalogChannelUnits
|    |    |-- AnalogPhysicalChannelNames
|    |    |-- CanEnable
|    |    |-- ChannelNames
|    |    |-- DeviceNames
|    |    |-- DigitalChannelNames
|    |    |-- DigitalPhysicalChannelNames
|    |    |-- Duration
|    |    |-- Enabled
|    |    |-- ExpectedScanCount
|    |    |-- IsAnalogChannelActive
|    |    |-- IsArmedOrAcquiring
|    |    |-- IsChannelActive
|    |    |-- IsChannelAnalog
|    |    |-- IsDigitalChannelActive
|    |    |-- IsReady
|    |    |-- NActiveAnalogChannels
|    |    |-- NActiveChannels
|    |    |-- NActiveDigitalChannels
|    |    |-- NAnalogChannels
|    |    |-- NChannels
|    |    |-- NDigitalChannels
|    |    |-- PhysicalChannelNames
|    |    |-- SampleRate
|    |    |-- TriggerScheme
|    |         |-- Edge
|    |         |-- Interval
|    |         |-- IsExternal
|    |         |-- IsExternalAllowed
|    |         |-- IsInternal
|    |         |-- IsReady
|    |         |-- Name
|    |         |-- PFIID
|    |         |-- RepeatCount
|    |         |-- Target
|    |              |-- CounterID
|    |              |-- DeviceName
|    |              |-- Edge
|    |              |-- Interval
|    |              |-- IsReady
|    |              |-- Name
|    |              |-- PFIID
|    |              |-- RepeatCount
|    |-- ClockAtExperimentStart
|    |-- Display
|    |    |-- CanEnable
|    |    |-- Enabled
|    |    |-- IsReady
|    |    |-- IsXSpanSlavedToAcquistionDuration
|    |    |-- NScopes
|    |    |-- Scopes
|    |    |    |-- element1
|    |    |    |    |-- AreColorsNormal
|    |    |    |    |-- AreYLimitsLockedTightToData
|    |    |    |    |-- ChannelColorIndex
|    |    |    |    |-- ChannelNames
|    |    |    |    |-- DoShowButtons
|    |    |    |    |-- IsGridOn
|    |    |    |    |-- IsReady
|    |    |    |    |-- IsVisibleWhenDisplayEnabled
|    |    |    |    |-- NChannels
|    |    |    |    |-- Tag
|    |    |    |    |-- Title
|    |    |    |    |-- XData
|    |    |    |    |-- XLim
|    |    |    |    |-- XOffset
|    |    |    |    |-- XSpan
|    |    |    |    |-- XUnits
|    |    |    |    |-- YData
|    |    |    |    |    |-- element1
|    |    |    |    |-- YLim
|    |    |    |    |-- YScale
|    |    |    |    |-- YUnits
|    |    |    |-- element2
|    |    |    |    |-- AreColorsNormal
|    |    |    |    |-- AreYLimitsLockedTightToData
|    |    |    |    |-- ChannelColorIndex
|    |    |    |    |-- ChannelNames
|    |    |    |    |-- DoShowButtons
|    |    |    |    |-- IsGridOn
|    |    |    |    |-- IsReady
|    |    |    |    |-- IsVisibleWhenDisplayEnabled
|    |    |    |    |-- NChannels
|    |    |    |    |-- Tag
|    |    |    |    |-- Title
|    |    |    |    |-- XData
|    |    |    |    |-- XLim
|    |    |    |    |-- XOffset
|    |    |    |    |-- XSpan
|    |    |    |    |-- XUnits
|    |    |    |    |-- YData
|    |    |    |    |    |-- element1
|    |    |    |    |-- YLim
|    |    |    |    |-- YScale
|    |    |    |    |-- YUnits
|    |    |    |-- element3
|    |    |    |    |-- AreColorsNormal
|    |    |    |    |-- AreYLimitsLockedTightToData
|    |    |    |    |-- ChannelColorIndex
|    |    |    |    |-- ChannelNames
|    |    |    |    |-- DoShowButtons
|    |    |    |    |-- IsGridOn
|    |    |    |    |-- IsReady
|    |    |    |    |-- IsVisibleWhenDisplayEnabled
|    |    |    |    |-- NChannels
|    |    |    |    |-- Tag
|    |    |    |    |-- Title
|    |    |    |    |-- XData
|    |    |    |    |-- XLim
|    |    |    |    |-- XOffset
|    |    |    |    |-- XSpan
|    |    |    |    |-- XUnits
|    |    |    |    |-- YData
|    |    |    |    |    |-- element1
|    |    |    |    |-- YLim
|    |    |    |    |-- YScale
|    |    |    |    |-- YUnits
|    |    |    |-- element4
|    |    |    |    |-- AreColorsNormal
|    |    |    |    |-- AreYLimitsLockedTightToData
|    |    |    |    |-- ChannelColorIndex
|    |    |    |    |-- ChannelNames
|    |    |    |    |-- DoShowButtons
|    |    |    |    |-- IsGridOn
|    |    |    |    |-- IsReady
|    |    |    |    |-- IsVisibleWhenDisplayEnabled
|    |    |    |    |-- NChannels
|    |    |    |    |-- Tag
|    |    |    |    |-- Title
|    |    |    |    |-- XData
|    |    |    |    |-- XLim
|    |    |    |    |-- XOffset
|    |    |    |    |-- XSpan
|    |    |    |    |-- XUnits
|    |    |    |    |-- YData
|    |    |    |    |    |-- element1
|    |    |    |    |-- YLim
|    |    |    |    |-- YScale
|    |    |    |    |-- YUnits
|    |    |    |-- element5
|    |    |         |-- AreColorsNormal
|    |    |         |-- AreYLimitsLockedTightToData
|    |    |         |-- ChannelColorIndex
|    |    |         |-- ChannelNames
|    |    |         |-- DoShowButtons
|    |    |         |-- IsGridOn
|    |    |         |-- IsReady
|    |    |         |-- IsVisibleWhenDisplayEnabled
|    |    |         |-- NChannels
|    |    |         |-- Tag
|    |    |         |-- Title
|    |    |         |-- XData
|    |    |         |-- XLim
|    |    |         |-- XOffset
|    |    |         |-- XSpan
|    |    |         |-- XUnits
|    |    |         |-- YData
|    |    |         |    |-- element1
|    |    |         |-- YLim
|    |    |         |-- YScale
|    |    |         |-- YUnits
|    |    |-- UpdateRate
|    |    |-- XAutoScroll
|    |    |-- XOffset
|    |    |-- XSpan
|    |-- Ephys
|    |    |-- CanEnable
|    |    |-- ElectrodeManager
|    |    |    |-- AreSoftpanelsEnabled
|    |    |    |-- DidLastElectrodeUpdateWork
|    |    |    |-- Electrodes
|    |    |    |-- IsElectrodeMarkedForRemoval
|    |    |    |-- IsElectrodeMarkedForTestPulse
|    |    |    |-- IsInControlOfSoftpanelModeAndGains
|    |    |    |-- IsReady
|    |    |    |-- NElectrodes
|    |    |    |-- TestPulseElectrodeNames
|    |    |    |-- TestPulseElectrodes
|    |    |-- Enabled
|    |    |-- IsReady
|    |-- ExperimentCompletedTrialCount
|    |-- ExperimentTrialCount
|    |-- FastProtocols
|    |    |-- element1
|    |    |    |-- AutoStartType
|    |    |    |-- IsNonempty
|    |    |    |-- IsReady
|    |    |    |-- ProtocolFileName
|    |    |-- element2
|    |    |    |-- AutoStartType
|    |    |    |-- IsNonempty
|    |    |    |-- IsReady
|    |    |    |-- ProtocolFileName
|    |    |-- element3
|    |    |    |-- AutoStartType
|    |    |    |-- IsNonempty
|    |    |    |-- IsReady
|    |    |    |-- ProtocolFileName
|    |    |-- element4
|    |    |    |-- AutoStartType
|    |    |    |-- IsNonempty
|    |    |    |-- IsReady
|    |    |    |-- ProtocolFileName
|    |    |-- element5
|    |    |    |-- AutoStartType
|    |    |    |-- IsNonempty
|    |    |    |-- IsReady
|    |    |    |-- ProtocolFileName
|    |    |-- element6
|    |         |-- AutoStartType
|    |         |-- IsNonempty
|    |         |-- IsReady
|    |         |-- ProtocolFileName
|    |-- HasUserSpecifiedProtocolFileName
|    |-- HasUserSpecifiedUserSettingsFileName
|    |-- IndexOfSelectedFastProtocol
|    |-- IsContinuous
|    |-- IsReady
|    |-- IsTrialBased
|    |-- IsYokedToScanImage
|    |-- Logging
|    |    |-- AugmentedBaseName
|    |    |-- CanEnable
|    |    |-- CurrentTrialSetAbsoluteFileName
|    |    |-- DoIncludeDate
|    |    |-- DoIncludeSessionIndex
|    |    |-- Enabled
|    |    |-- FileBaseName
|    |    |-- FileLocation
|    |    |-- IsOKToOverwrite
|    |    |-- IsReady
|    |    |-- NextTrialIndex
|    |    |-- NextTrialSetAbsoluteFileName
|    |    |-- SessionIndex
|    |-- NFastProtocols
|    |-- NTimesSamplesAcquiredCalledSinceExperimentStart
|    |-- State
|    |-- Stimulation
|    |    |-- AnalogChannelNames
|    |    |-- AnalogChannelScales
|    |    |-- AnalogChannelUnits
|    |    |-- AnalogPhysicalChannelNames
|    |    |-- CanEnable
|    |    |-- ChannelNames
|    |    |-- DeviceNamePerAnalogChannel
|    |    |-- DigitalChannelNames
|    |    |-- DigitalOutputStateIfUntimed
|    |    |-- DigitalPhysicalChannelNames
|    |    |-- DoRepeatSequence
|    |    |-- Enabled
|    |    |-- IsArmedOrStimulating
|    |    |-- IsChannelAnalog
|    |    |-- IsDigitalChannelTimed
|    |    |-- IsReady
|    |    |-- IsWithinExperiment
|    |    |-- NAnalogChannels
|    |    |-- NChannels
|    |    |-- NDigitalChannels
|    |    |-- NTimedDigitalChannels
|    |    |-- PhysicalChannelNames
|    |    |-- SampleRate
|    |    |-- StimulusLibrary
|    |    |    |-- IsReady
|    |    |    |-- SelectedOutputable
|    |    |         |-- ChannelNames
|    |    |         |-- Duration
|    |    |         |-- IsDurationFree
|    |    |         |-- IsLive
|    |    |         |-- IsMarkedForDeletion
|    |    |         |-- IsReady
|    |    |         |-- Multipliers
|    |    |         |-- NBindings
|    |    |         |-- Name
|    |    |         |-- Stimuli
|    |    |              |-- element1
|    |    |                   |-- Amplitude
|    |    |                   |-- DCOffset
|    |    |                   |-- Delay
|    |    |                   |-- Delegate
|    |    |                   |    |-- IsReady
|    |    |                   |    |-- TypeString
|    |    |                   |-- Duration
|    |    |                   |-- EndTime
|    |    |                   |-- IsReady
|    |    |                   |-- Name
|    |    |                   |-- TypeString
|    |    |-- TriggerScheme
|    |         |-- Edge
|    |         |-- Interval
|    |         |-- IsExternal
|    |         |-- IsExternalAllowed
|    |         |-- IsInternal
|    |         |-- IsReady
|    |         |-- Name
|    |         |-- PFIID
|    |         |-- RepeatCount
|    |         |-- Target
|    |              |-- CounterID
|    |              |-- DeviceName
|    |              |-- Edge
|    |              |-- Interval
|    |              |-- IsReady
|    |              |-- Name
|    |              |-- PFIID
|    |              |-- RepeatCount
|    |-- TrialDuration
|    |-- Triggering
|    |    |-- AcquisitionTriggerScheme
|    |    |    |-- Edge
|    |    |    |-- Interval
|    |    |    |-- IsExternal
|    |    |    |-- IsExternalAllowed
|    |    |    |-- IsInternal
|    |    |    |-- IsReady
|    |    |    |-- Name
|    |    |    |-- PFIID
|    |    |    |-- RepeatCount
|    |    |    |-- Target
|    |    |    |    |-- CounterID
|    |    |    |    |-- DeviceName
|    |    |    |    |-- Edge
|    |    |    |    |-- Interval
|    |    |    |    |-- IsReady
|    |    |    |    |-- Name
|    |    |    |    |-- PFIID
|    |    |    |    |-- RepeatCount
|    |    |-- AcquisitionUsesASAPTriggering
|    |    |-- CanEnable
|    |    |-- Destinations
|    |    |    |-- element1
|    |    |    |    |-- DeviceName
|    |    |    |    |-- Edge
|    |    |    |    |-- IsReady
|    |    |    |    |-- Name
|    |    |    |    |-- PFIID
|    |    |    |-- element2
|    |    |         |-- DeviceName
|    |    |         |-- Edge
|    |    |         |-- IsReady
|    |    |         |-- Name
|    |    |         |-- PFIID
|    |    |-- Enabled
|    |    |-- IsReady
|    |    |-- IsStimulationCounterTriggerTaskRunning
|    |    |-- MinDurationBetweenTrialsIfNotASAP
|    |    |-- Sources
|    |    |    |-- element1
|    |    |    |    |-- CounterID
|    |    |    |    |-- DeviceName
|    |    |    |    |-- Edge
|    |    |    |    |-- Interval
|    |    |    |    |-- IsReady
|    |    |    |    |-- Name
|    |    |    |    |-- PFIID
|    |    |    |    |-- RepeatCount
|    |    |    |-- element2
|    |    |         |-- CounterID
|    |    |         |-- DeviceName
|    |    |         |-- Edge
|    |    |         |-- Interval
|    |    |         |-- IsReady
|    |    |         |-- Name
|    |    |         |-- PFIID
|    |    |         |-- RepeatCount
|    |    |-- StimulationTriggerScheme
|    |    |    |-- Edge
|    |    |    |-- Interval
|    |    |    |-- IsExternal
|    |    |    |-- IsExternalAllowed
|    |    |    |-- IsInternal
|    |    |    |-- IsReady
|    |    |    |-- Name
|    |    |    |-- PFIID
|    |    |    |-- RepeatCount
|    |    |    |-- Target
|    |    |         |-- CounterID
|    |    |         |-- DeviceName
|    |    |         |-- Edge
|    |    |         |-- Interval
|    |    |         |-- IsReady
|    |    |         |-- Name
|    |    |         |-- PFIID
|    |    |         |-- RepeatCount
|    |    |-- StimulationUsesAcquisitionTriggerScheme
|    |-- UserFunctions
|         |-- AbortCallsComplete
|         |-- CanEnable
|         |-- ClassName
|         |-- Enabled
|         |-- IsReady
|         |-- TheObject
|-- trial_0001
     |-- analogScans
     |-- timestamp

````
Meta data is contained in the group `header`
