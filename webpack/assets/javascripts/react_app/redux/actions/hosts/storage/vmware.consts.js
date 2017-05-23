/* eslint-disable */

export const defaultConrollerAttributes = {
  type: 'ParaVirtualSCSIController'
};

const _defaultDiskAttributes = () => ({
  sizeGb: '10',
  datastore: '',
  storagePod: '',
  thin: false,
  eagerZero: false,
  name: __('Hard disk'),
  mode: ''
});

export const getDefaultDiskAttributes = _defaultDiskAttributes;
