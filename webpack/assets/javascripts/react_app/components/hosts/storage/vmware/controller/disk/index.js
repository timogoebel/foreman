import React from 'react';
import {Button} from 'react-bootstrap';
import Select from '../../../../../common/forms/Select';
import Checkbox from '../../../../../common/forms/Checkbox';
import TextInput from '../../../../../common/forms/TextInput';
import './disk.scss';

const Disk = ({
  removeDisk,
  updateDisk,
  name,
  storagePod,
  datastores,
  storagePods,
  dataStore,
  size,
  thinProvision,
  eagerZero,
  mode,
  diskModeTypes
}) => {

  return (
    <div className="disk-container">
      <div className="form-group">
        <label className="col-md-2 control-label">
          {__('Disk name')}
        </label>
        <div className="col-md-4">
          {name}
        </div>
      </div>
      {
        !dataStore && storagePods.length > 0 &&
        <Select
          label={__('Storage Pod')}
          value={storagePod}
          onChange={updateDisk.bind(this, 'storagePod')}
          options={storagePods}/>
      }
      {
        !storagePod &&
        <Select
          label={__('Data store')}
          value={dataStore}
          onChange={updateDisk.bind(this, 'dataStore')}
          options={datastores}/>
      }

      <Select
        label={__('mode')}
        value={mode}
        onChange={updateDisk.bind(this, 'mode')}
        options={diskModeTypes}/>

      <TextInput
        value={size}
        className="text-vmware-size"
        onChange={updateDisk.bind(this, 'size')}
        label={__('Size (GB)')}/>

      <Checkbox
        label={__('Thin provision')}
        checked={thinProvision}
        onChange={updateDisk.bind(this, 'thinProvision')}/>

      <Checkbox
        label={__('Eager zero')}
        checked={eagerZero}
        onChange={updateDisk.bind(this, 'eagerZero')}/>
      <div className="delete-volume-container form-group">
        <Button onClick={removeDisk}>
          {__('Delete volume')}
        </Button>
      </div>
    </div>
  );
};

export default Disk;
