function lsl_close_inlet(inlet_name)
% Drop the current data stream.
% close_stream()
%
% All samples that are still buffered or in flight will be dropped and the source will halt its buffering of data for this inlet.
% If an application stops being interested in data from a source (temporarily or not) but keeps the outlet alive, it should
% call close_streams() to not pressure the source outlet to buffer unnecessarily large amounts of data.

lsl_close_stream(inlet_name.LibHandle, inlet_name.InletHandle);