import React from 'react';
import CommonForm from './CommonForm';
import $ from 'jquery';

class Select extends React.Component {
  componentDidMount() {
    if ($.fn.select2) {
      $(this.refs.select).select2();
    }
  }

  render() {
    const {
      label,
      className = '',
      value,
      onChange,
      options
    } = this.props;

    return (
      <CommonForm label={label} className={`common-select ${className}`}>
        <select
          ref="select"
          className="form-control"
          value={value}
          onChange={onChange}
        >
          <option value="">{__('Please select')}</option>
          {options}
        </select>
      </CommonForm>
    );
  }
}

export default Select;
