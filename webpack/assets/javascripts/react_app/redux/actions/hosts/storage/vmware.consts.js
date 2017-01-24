export const defaultConrollerAttributes = {
  type: 'ParaVirtualSCSIController'
};

const _defaultDiskAttributes = () => ({
  size: '10',
  dataStore: '',
  storagePod: '',
  thinProvision: false,
  eagerZero: false,
  name: __('Hard disk'),
  mode: ''
});

export const getDefaultDiskAttributes = _defaultDiskAttributes;
