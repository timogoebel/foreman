import { SHOW_FORM } from '../../../consts';
import Immutable from 'seamless-immutable';

const initialState = Immutable({
  action: 'button'
});

export default (state = initialState, action) => {
  const { payload } = action;

  switch (action.type) {
    case SHOW_FORM: {
      return state.set('action', 'form');
    }

    default: {
      return state;
    }
  }
};
