import React, { Component } from 'react'
import CreateButton from './createButton/';
import TokenForm from './tokenForm/';
import MessageBox from '../common/MessageBox';
import * as PersonalAccessTokenActions from '../../redux/actions/personalAccessTokens';
import { connect } from 'react-redux';

class PersonalAccessToken extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    const { showForm } = this.props;

    switch (this.props.action) {
      case 'button': {
        return  (<CreateButton onClick={showForm.bind(this)} />);
      }
      case 'form': {
        return (<TokenForm />);
      }
      default: {
        return (<MessageBox icontype="error-circle-o" msg={"Invalid Status: " + this.props.action} />);
      }
    }
  }
}

const mapStateToProps = state => ({
  action: state.personalAccessTokens.action
});

export default connect(mapStateToProps, PersonalAccessTokenActions)(PersonalAccessToken);
