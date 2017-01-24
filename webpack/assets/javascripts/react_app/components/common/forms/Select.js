import React from 'react';
import CommonForm from './CommonForm';
import $ from 'jquery';
import {map} from 'lodash';

class Select extends React.Component {
  componentDidMount() {
    if ($.fn.select2) {
      $(this.refs.select)
        .select2()
        .on('change', this.props.onChange);
    }
  }

  render() {
    const renderOptions = (arr) => map(arr, (attribute, v) => {
      const key = Object.keys(attribute)[0];
      const value = Object.values(attribute)[0];

      return <option key={key} value={key}>{value}</option>;
    });

    const {
      label,
      className = '',
      value,
      onChange,
      options
    } = this.props;

    const innerSelect = (
      <select ref="select" className="form-control" value={value} onChange={onChange}>
        <option value="">{__('Please select')}</option>
        {renderOptions(options)}
      </select>
    );

    if (!label) {
      return innerSelect;
    }
    return (
      <CommonForm label={label} className={`common-select ${className}`}>
        {innerSelect}
      </CommonForm>
    );
  }
}

export default Select;