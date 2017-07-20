import React from 'react';
import TextInput from '../../../common/forms/TextInput';
import Submit from '../../../common/forms/Submit';

class TokenForm extends React.Component {
  render() {
    return (
      <form className="form-horizontal well">
        <TextInput label={__('name')} ></TextInput>
        <Submit onSubmit={() => console.log('submit')} />
      </form>
    );
  }
}
export default TokenForm;
