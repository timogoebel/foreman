import { STORAGE_VMWARE_ADD_CONTROLLER } from '../../../consts';
import {
  defaultConrollerAttributes,
  defaultDiskAttributes
} from './vmeware.consts';

export const loadController = defaultData => {
  return {
    type: STORAGE_VMWARE_ADD_CONTROLLER,
    payload: {
      disks: [Object.assign({}, defaultDiskAttributes)],
      ...defaultData,
      ...defaultConrollerAttributes
    }
  };
};

//addDisk, removeController, updateController
