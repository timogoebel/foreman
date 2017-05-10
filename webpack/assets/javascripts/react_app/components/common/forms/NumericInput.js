import React from 'react';
import CommonForm from './CommonForm';
import NumericInput from 'react-numeric-input';

const TextInput = ({
  label,
  className = '',
  value,
  onChange
}) => {
  const format = num => `${num} gb`;

  return (
    <CommonForm label={label}
    className={`common-numericInput ${className}`}>
      <NumericInput format={ format }
        min={0}
        value={value}
        onChange={onChange}/>
    </CommonForm>
  );
};

export default TextInput;
