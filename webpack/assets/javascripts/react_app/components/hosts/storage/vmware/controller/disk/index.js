/* eslint-disable camelcase */
import React from 'react';
import Select from '../../../../../common/forms/Select';
import Checkbox from '../../../../../common/forms/Checkbox';
import NumericInput from '../../../../../common/forms/NumericInput';
import './disk.scss';

const Disk = ({
  removeDisk,
  updateDisk,
  name,
  config: { datastores, storagePods, diskModeTypes },
  storagePod,
  dataStore,
  sizeGb,
  thin,
  eagerZero,
  mode
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
        <div className="col-md-2">
          <button
            type="button"
            className="close"
            onClick={removeDisk}
            aria-label="Close"
          >
            <span aria-hidden="true">×</span>
          </button>
        </div>
      </div>
      {!dataStore &&
        <Select
          label={__('Storage Pod')}
          value={storagePod}
          onChange={updateDisk.bind(this, 'storagePod')}
          options={storagePods}
        />}
      {!storagePod &&
        <Select
          label={__('Data store')}
          value={dataStore}
          onChange={updateDisk.bind(this, 'datastore')}
          options={datastores}
        />}

      <Select
        label={__('Disk Mode')}
        value={mode}
        onChange={updateDisk.bind(this, 'mode')}
        options={diskModeTypes}
      />

      <NumericInput
        value={sizeGb}
        format={v => `${v} GB`}
        className="text-vmware-size"
        onChange={updateDisk.bind(this, 'sizeGb')}
        label={__('Size (GB)')}
      />

      <Checkbox
        label={__('Thin provision')}
        checked={thin}
        onChange={updateDisk.bind(this, 'thin')}
      />

      <Checkbox
        label={__('Eager zero')}
        checked={eagerZero}
        onChange={updateDisk.bind(this, 'eagerZero')}
      />
    </div>
  );
};

export default Disk;
