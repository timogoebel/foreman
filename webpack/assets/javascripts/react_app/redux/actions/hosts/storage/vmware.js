import {
  STORAGE_VMWARE_ADD_CONTROLLER,
  STORAGE_VMWARE_ADD_DISK,
  STORAGE_VMWARE_REMOVE_CONTROLLER,
  STORAGE_VMWARE_UPDATE_CONTROLLER,
  STORAGE_VMWARE_REMOVE_DISK,
  STORAGE_VMWARE_UPDATE_DISK,
  STORAGE_VMWARE_INIT
} from '../../../consts';
import {
  defaultConrollerAttributes,
  getDefaultDiskAttributes
} from './vmware.consts';

export const updateDisk = (controllerIdx, diskIdx, newValues) => ({
  type: STORAGE_VMWARE_UPDATE_DISK,
  payload: {
    controllerIdx,
    diskIdx,
    newValues
  }
});

const defaultPayload = defaultData => ({
  disks: [Object.assign({}, getDefaultDiskAttributes())],
    ...defaultData,
    ...defaultConrollerAttributes
});

export const initController = data => ({
  type: STORAGE_VMWARE_INIT,
  payload: defaultPayload(data)
});

export const addController = data => ({
  type: STORAGE_VMWARE_ADD_CONTROLLER,
  payload: defaultPayload(data)
});

export const updateController = (idx, newValues) => ({
  type: STORAGE_VMWARE_UPDATE_CONTROLLER,
  payload: {
    idx,
    newValues
  }
});

export const removeDisk = (controllerIdx, diskIdx) => ({
  type: STORAGE_VMWARE_REMOVE_DISK,
  payload: {
    controllerIdx,
    diskIdx
  }
});

export const removeController = (idx) => ({
  type: STORAGE_VMWARE_REMOVE_CONTROLLER,
  payload: { idx }
});

export const addDisk = idx => ({
  type: STORAGE_VMWARE_ADD_DISK,
  payload: {
    idx,
    data: getDefaultDiskAttributes()
  }
});
