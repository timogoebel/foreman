import {InitialSCSIKey} from './StorageContainer.consts';

export const MaxDisksPerController = 15;
export const ControllerTypes = {
  VirtualBusLogicController: 'Bus Logic Parallel',
  VirtualLsiLogicController: 'LSI Logic Parallel',
  VirtualLsiLogicSASController: 'LSI Logic SAS',
  ParaVirtualSCSIController: 'VMware Paravirtual'
};

export const controllersToJsonString = (controllers) => {
  return JSON.stringify(controllers.reduce((curr, controller, idx) => Object.assign({}, curr, {
    scsiControllers: curr
      .scsiControllers
      .concat({
        key: InitialSCSIKey + idx,
        type: controller.type
      }),
    volumes: curr
      .volumes
      .concat(controller.disks.map(disk => {
        const retVal = {
          sizeGb: disk.size,
          storagePod: disk.storagePod,
          thin: disk.thinProvision,
          datastore: disk.dataStore,
          eagerZero: disk.eagerZero,
          controllerKey: InitialSCSIKey + idx,
          name: disk.name,
          mode: disk.mode
        };

        return retVal;
      }))
  }), {
    scsiControllers: [],
    volumes: []
  }));
};
