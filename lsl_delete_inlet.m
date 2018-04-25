function lsl_delete_inlet(inlet_name)
% Destroy the inlet when it is deleted.
% The inlet will automatically disconnect if destroyed.

lsl_destroy_inlet(inlet_name.LibHandle,inlet_name.InletHandle);