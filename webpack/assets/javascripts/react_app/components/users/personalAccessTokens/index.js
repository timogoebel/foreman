import React from 'react';
import Button from '../../common/forms/Button';
import TokenForm from './tokenForm/';
import MessageBox from '../../common/MessageBox';
import * as PersonalAccessTokenActions from '../../../redux/actions/users/personalAccessTokens';
import { connect } from 'react-redux';

class PersonalAccessToken extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    const { showForm } = this.props;

    switch (this.props.action) {
      case 'button': {
        return (
          <Button className="btn-success" onClick={showForm.bind(this)} >
            {__('Create Personal Access Token')}
          </Button>
        );
      }
      case 'form': {
        return <TokenForm />;
      }
      default: {
        return (
          <MessageBox icontype="error-circle-o" msg={'Invalid Status: ' + this.props.action} />
        );
      }
    }
  }
}

const mapStateToProps = state => ({
  action: state.users.personalAccessTokens.action
});

export default connect(mapStateToProps, PersonalAccessTokenActions)(PersonalAccessToken);
