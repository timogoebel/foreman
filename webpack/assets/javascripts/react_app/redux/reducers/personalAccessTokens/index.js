import { SHOW_FORM } from '../../consts';
import Immutable from 'seamless-immutable';

const initialState = Immutable({
  action: 'button'
});

export default (state = initialState, action) => {
  const { payload } = action;

  switch (action.type) {
    //case TOASTS_ADD: {
    //  return state.setIn(['messages', payload.key], payload.message);
    //}

    //case TOASTS_DELETE: {
    //  return state.set('messages', state.messages.without(payload.key));
    //}

    case SHOW_FORM: {
      return state.set('action', 'form');
    }

    default: {
      return state;
    }
  }
};
