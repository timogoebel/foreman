import Immutable from 'seamless-immutable';
import {
  STORAGE_VMWARE_ADD_CONTROLLER,
  STORAGE_VMWARE_ADD_DISK,
  STORAGE_VMWARE_REMOVE_DISK,
  STORAGE_VMWARE_REMOVE_CONTROLLER,
  STORAGE_VMWARE_UPDATE_CONTROLLER,
  STORAGE_VMWARE_UPDATE_DISK,
  STORAGE_VMWARE_INIT
} from '../../../consts';
import { omit } from 'lodash';

const initialState = Immutable({
  controllers: []
});

export default (state = initialState, {type, payload}) => {
  switch (type) {
    case STORAGE_VMWARE_ADD_CONTROLLER:
      return state.update('controllers', ctrls => ctrls.concat(payload));
    case STORAGE_VMWARE_ADD_DISK:
      return state.updateIn(['controllers', payload.idx, 'disks'], list =>
        list.concat(payload.data));
    case STORAGE_VMWARE_REMOVE_CONTROLLER:
      return state.update('controllers', ctrls => ctrls.filter((ctrl, idx) => idx !== payload.idx));
    case STORAGE_VMWARE_UPDATE_CONTROLLER:
      return state.updateIn(['controllers', payload.idx], controller =>
        Object.assign({}, controller, payload.newValues));
    case STORAGE_VMWARE_UPDATE_DISK:
      return state.updateIn(
        ['controllers', payload.controllerIdx, 'disks', payload.diskIdx],
        disk => Object.assign({}, disk, payload.newValues)
      );
    case STORAGE_VMWARE_REMOVE_DISK:
      return state.updateIn(['controllers', payload.controllerIdx, 'disks'], disks =>
        disks.filter((i, idx) => idx !== payload.diskIdx));
    case STORAGE_VMWARE_INIT:
      return initialState
        .set(
          'controllerTypes',
          Object.keys(payload.controller_types).map((key) => ({
            [key]: payload.controller_types[key]
          }))
        )
        .update(
          'controllers',
          ctrls => ctrls.concat(
            omit(payload, 'controller_types')
          )
        );
    default:
      return state;
  }
};
