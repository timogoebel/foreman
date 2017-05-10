import React from 'react';
import CommonForm from './CommonForm';
import NumericInput from 'react-numeric-input';

const TextInput = ({
  label,
  className = '',
  value,
  onChange,
  format,
  minValue = 0
}) => {
  return (
    <CommonForm label={label}
    className={`common-numericInput ${className}`}>
      <NumericInput format={ format }
        min={minValue}
        value={value}
        onChange={onChange}/>
    </CommonForm>
  );
};

export default TextInput;
