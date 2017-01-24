import VMStorageVMWare from './vmeware.consts';

const _controllers = [0, 1, 2, 3].map(position => ({
  position,
  SCSIKey: VMStorageVMWare.InitialSCSIKey + position,
  disks: [],
  enabled: false
}));

export const getEnabledControllers = () => _controllers.filter(
  f => f.enabled
);
