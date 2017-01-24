import Immutable from 'seamless-immutable';
import {
  STORAGE_VMWARE_ADD_CONTROLLER
} from '../../../consts';
const initialState = Immutable({
  controllers: []
});

export default (state = initialState, action) => {
  switch (action.type) {
    case STORAGE_VMWARE_ADD_CONTROLLER:
      return state.set('controllers', state.controllers.concat(action.payload));
    default: return state;
  }
};
