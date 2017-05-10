import React from 'react';
import CommonForm from './CommonForm';
const Checkbox = ({
  className = '',
  checked,
  onChange,
  label
}) => {
  return (
    <CommonForm label={label}
    className={`common-checkbox ${className}`}>
      <input
        type="checkbox"
        checked={checked}
        onChange={onChange}/>
    </CommonForm>
  );
};

export default Checkbox;
