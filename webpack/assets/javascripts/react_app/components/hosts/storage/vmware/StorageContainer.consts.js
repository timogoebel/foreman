export const MaxDisksPerController = 15;
export const MaxControllers = 4;
export const InitialSCSIKey = 1000;
export const getDiskModeTypes = () => [{
    'persistent': __('Independent - Persistent')},
    {'independent_persistent': __('Independent - Persistent')},
    {'independent_nonpersistent': __('Independent - Nonpersistent')}
];
