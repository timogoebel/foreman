/* eslint-disable */
export const vmwareData = {
  config: {
    controllerTypes: {
      VirtualBusLogicController: 'Bus Logic Parallel',
      VirtualLsiLogicController: 'LSI Logic Parallel',
      VirtualLsiLogicSASController: 'LSI Logic SAS',
      ParaVirtualSCSIController: 'VMware Paravirtual'
    },
    diskModeTypes: {
      persistent: 'Persistent',
      independent_persistent: 'Independent - Persistent',
      independent_nonpersistent: 'Independent - Nonpersistent'
    },
    storagePods: {
      StorageCluster: 'StorageCluster (free: 1.01 TB, prov: 7.49 TB, total: 8.5 TB)'
    },
    datastores: {
      'cfme-esx-55-01-local': 'cfme-esx-55-01-local (free: 524 GB, prov: 465 GB, total: 924 GB)',
      'cfme-esx-55-03-local': 'cfme-esx-55-03-local (free: 898 GB, prov: 165 GB, total: 924 GB)',
      'cfme-esx-55-04-local': 'cfme-esx-55-04-local (free: 250 GB, prov: 681 GB, total: 924 GB)',
      'cfme-esx-55-na01a': 'cfme-esx-55-na01a (free: 448 GB, prov: 8.56 TB, total: 4 TB)',
      'cfme-esx-55-na01b': 'cfme-esx-55-na01b (free: 587 GB, prov: 7.25 TB, total: 4.5 TB)',
      'cfme-esx-admin-lun-na01b': 'cfme-esx-admin-lun-na01b (free: 553 GB, prov: 519 GB, total: 1020 GB)',
      'cfme-esx-glob-na01a-s': 'cfme-esx-glob-na01a-s (free: 1.45 TB, prov: 3.49 TB, total: 1.9 TB)',
      'cfme-esx-glob-na01b-s': 'cfme-esx-glob-na01b-s (free: 1.37 TB, prov: 2.22 TB, total: 1.9 TB)',
      'cfme-iso-glob-na01a-s': 'cfme-iso-glob-na01a-s (free: 341 GB, prov: 134 GB, total: 475 GB)',
      'do-not-use-datastore': 'do-not-use-datastore (free: 462 GB, prov: 12.6 GB, total: 475 GB)',
      'do-not-use-host-prov': 'do-not-use-host-prov (free: 0 Bytes, prov: 973 MB, total: 973 MB)',
      master_iso_rdu: 'master_iso_rdu (free: 689 GB, prov: 289 GB, total: 973 GB)',
      temp_store: 'temp_store (free: 475 GB, prov: 19.5 MB, total: 475 GB)',
      vsanDatastore: 'vsanDatastore (free: 207 GB, prov: 26.1 GB, total: 233 GB)'
    }
  },
  volumes: [
    {
      thin: true,
      name: 'Hard disk',
      mode: 'persistent',
      controllerKey: 1000,
      size: 10485760,
      sizeGb: 10
    }
  ],
  controllers: [{ type: 'VirtualLsiLogicController', key: 1000 }]
};

export const vmwareData2 = {
  config: {
    controllerTypes: {
      VirtualBusLogicController: 'Bus Logic Parallel',
      VirtualLsiLogicController: 'LSI Logic Parallel',
      VirtualLsiLogicSASController: 'LSI Logic SAS',
      ParaVirtualSCSIController: 'VMware Paravirtual'
    },
    diskModeTypes: {
      persistent: 'Persistent',
      independent_persistent: 'Independent - Persistent',
      independent_nonpersistent: 'Independent - Nonpersistent'
    },
    storagePods: {},
    datastores: {
      'Local-Bulgaria': 'Local-Bulgaria (free: 4.62 TB, prov: 2.34 TB, total: 5.91 TB)',
      'Local-Ironforge': 'Local-Ironforge (free: 1.49 TB, prov: 1.3 TB, total: 2.72 TB)',
      'Local-Jericho': 'Local-Jericho (free: 1.99 TB, prov: 3.02 TB, total: 4.09 TB)',
      'Local-Nightwing': 'Local-Nightwing (free: 591 GB, prov: 182 GB, total: 756 GB)',
      'Local-Supermicro': 'Local-Supermicro (free: 599 GB, prov: 317 GB, total: 917 GB)',
      'NFS-Engineering': 'NFS-Engineering (free: 2.3 TB, prov: 1.74 TB, total: 2.64 TB)'
    }
  },
  controllers: [
    {
      type: 'VirtualLsiLogicController',
      sharedBus: 'noSharing',
      unitNumber: 7,
      key: 1000
    }
  ],
  volumes: [
    {
      thin: true,
      name: 'Hard disk 1',
      mode: 'persistent',
      controllerKey: 1000,
      serverId: '502e324d-a2af-108b-1e10-b6d9eddfc53a',
      datastore: 'Local-Ironforge',
      id: '6000C297-9a11-998a-fc7c-8125ce9042a3',
      filename: '[Local-Ironforge] wanda-marcial.www.somedomain.com/wanda-marcial.www.somedomain.com.vmdk',
      size: 20971520,
      key: 2000,
      unitNumber: 0
    }
  ]
};
