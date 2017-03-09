export const vmwareData = {
  'storage_pods': [
    {
      StorageCluster: 'StorageCluster (free: 1.15 TB, prov: 7.35 TB, total: 8.5 TB)'
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
  ]
};

export const hiddenFieldValue = {
  scsiControllers: [{ key: 1000, type: 'ParaVirtualSCSIController' }],
  volumes: [
    {
      controllerKey: 1000,
      datastore: '',
      eagerZero: false,
      name: 'Hard disk',
      sizeGb: '10',
      storagePod: '',
      thin: false
    }
  ]
};
