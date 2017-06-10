import React, { Component } from 'react'

class CreateButton extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    return (
      <a className="btn btn-success" onClick={this.props.onClick}>{__('Create Personal Access Token')}</a>
    )
  }
}

export default CreateButton;
