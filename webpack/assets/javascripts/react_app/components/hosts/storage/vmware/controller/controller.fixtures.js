export const props = {
  controller: {
    disks: [
      {
        size: '10',
        dataStore: '',
        storagePod: '',
        thinProvision: false,
        eagerZero: false,
        name: 'Hard disk'
      }
    ],
    'storage_pods': [
      {
        StorageCluster: 'StorageCluster (free: 1.15 TB, prov: 7.35 TB, total: 8.5 TB)'
      },
      {
        StorageCluster22: 'StorageCluster22 (free: 15 TB, prov: 7 TB, total: 18 TB)'
      }
    ],
    datastores: [
      {
        'cfme-esx-55-01-local': 'cfme-esx-55-01-local (free: 614 GB, prov: 348 GB, total: 924 GB)'
      },
      {
        'cfme-esx-55-03-local': 'cfme-esx-55-03-local (free: 886 GB, prov: 188 GB, total: 924 GB)'
      },
      {
        'cfme-esx-55-04-local': 'cfme-esx-55-04-local (free: 104 GB, prov: 824 GB, total: 924 GB)'
      },
      {
        'cfme-esx-55-na01a': 'cfme-esx-55-na01a (free: 548 GB, prov: 8.16 TB, total: 4 TB)'
      }
    ],
    type: 'ParaVirtualSCSIController'
  },
  addDiskEnabled: true,
  ControllerTypes: {
    VirtualBusLogicController: 'Bus Logic Parallel',
    VirtualLsiLogicController: 'LSI Logic Parallel',
    VirtualLsiLogicSASController: 'LSI Logic SAS',
    ParaVirtualSCSIController: 'VMware Paravirtual'
  },
  addDisk: () => {},
  removeDisk: () => {},
  removeController: () => {},
  updateController: () => {},
  updateDisk: () => {}
};
