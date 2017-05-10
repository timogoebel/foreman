import Immutable from 'seamless-immutable';
import {makeUUid} from '../../../../common/uuid';
import {
  STORAGE_VMWARE_ADD_CONTROLLER,
  STORAGE_VMWARE_ADD_DISK,
  STORAGE_VMWARE_REMOVE_DISK,
  STORAGE_VMWARE_REMOVE_CONTROLLER,
  STORAGE_VMWARE_UPDATE_CONTROLLER,
  STORAGE_VMWARE_UPDATE_DISK,
  STORAGE_VMWARE_INIT
} from '../../../consts';

const initialState = Immutable({
  controllers: []
});

export default (state = initialState, {type, payload}) => {
  switch (type) {
    case STORAGE_VMWARE_ADD_CONTROLLER:
      return state.update('controllers', ctrls => ctrls.concat(payload));
    case STORAGE_VMWARE_ADD_DISK:
      return state.set(
        'volumes',
        state.volumes.concat({
          ...payload.data,
          uuid: makeUUid(),
          'controller_key': payload.controllerKey
        })
      );
    case STORAGE_VMWARE_REMOVE_CONTROLLER:
      return state
        .update('controllers', ctrls => ctrls.filter(ctrl => ctrl.key !== payload.controllerKey))
        .update('volumes', volumes =>
          volumes.filter(volume => volume.controller_key !== payload.controllerKey));
    case STORAGE_VMWARE_UPDATE_CONTROLLER:
      return state.updateIn(['controllers', payload.idx], controller =>
        Object.assign({}, controller, payload.newValues));
    case STORAGE_VMWARE_UPDATE_DISK:
      return state.set(
        'volumes',
        state.volumes.map(
          v => v.uuid === payload.uuid ? Object.assign({}, v, payload.newValues) : v
        )
      );
    case STORAGE_VMWARE_REMOVE_DISK:
      return state.set('volumes', state.volumes.filter(v => v.uuid !== payload.uuid));
    case STORAGE_VMWARE_INIT:
      return initialState
        .set('config', payload.config)
        .set('controllers', payload.controllers)
        .set('volumes', payload.volumes.map(volume => ({...volume, uuid: makeUUid()})));
    default:
      return state;
  }
};
