import React from 'react';
import { Button } from 'react-bootstrap';
import Select from '../../../../../common/forms/Select';
import Checkbox from '../../../../../common/forms/Checkbox';
import TextInput from '../../../../../common/forms/TextInput';
import './disk.scss';

const Disk = (
  {
    removeDisk,
    updateDisk,
    name,
    storagePod,
    datastores,
    storagePods,
    dataStore,
    size,
    thinProvision,
    eagerZero
  }
) => {
  const renderOptions = (arr) => arr.map(attribute => {
    const key = Object.keys(attribute)[0];
    const value = Object.values(attribute)[0];

    return <option key={key} value={key}>{value}</option>;
  });
  const selectableStores = renderOptions(datastores);
  const selectablePods = renderOptions(storagePods);

  return (
    <div className="disk-container">
      <TextInput
        value={name}
        onChange={updateDisk.bind(this, 'name')}
        label={__('Disk name')}
      />

      <Select
        label={__('Storage Pod')}
        value={storagePod}
        onChange={updateDisk.bind(this, 'storagePod')}
        options={selectablePods}
      />

      <Select
        label={__('Data store')}
        value={dataStore}
        onChange={updateDisk.bind(this, 'dataStore')}
        options={selectableStores}
      />

      <TextInput
        value={size}
        className="text-vmware-size"
        onChange={updateDisk.bind(this, 'size')}
        label={__('Size (GB)')}
      />

      <Checkbox
        label={__('Thin provision')}
        checked={thinProvision}
        onChange={updateDisk.bind(this, 'thinProvision')}
      />

      <Checkbox
        label={__('Eager zero')}
        checked={eagerZero}
        onChange={updateDisk.bind(this, 'eagerZero')}
      />
      <div className="delete-volume-container form-group">
      <Button onClick={removeDisk} >
        {__('Delete volume')}
      </Button>
      </div>
    </div>
  );
};

export default Disk;
