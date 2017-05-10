/* eslint-disable */

export const defaultConrollerAttributes = {
  type: 'ParaVirtualSCSIController'
};

const _defaultDiskAttributes = () => ({
  size_gb: '10',
  dataStore: '',
  storagePod: '',
  thinProvision: false,
  eager_zero: false,
  name: __('Hard disk'),
  mode: ''
});

export const getDefaultDiskAttributes = _defaultDiskAttributes;
