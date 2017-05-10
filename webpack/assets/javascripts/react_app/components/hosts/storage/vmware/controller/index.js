import React from 'react';
import { Button } from 'react-bootstrap';
import Disk from './disk';
import './controller.scss';
import Select from '../../../../common/forms/Select';
const Controller = (
  {
    addDiskEnabled,
    addDisk,
    removeDisk,
    updateController,
    updateDisk,
    ControllerTypes,
    controller,
		controllerVolumes,
    removeController,
    config
  }
) => {
  const getEventValue = e => {
    if (!e.target) {
      return e;
    }
    return e.target.type === 'checkbox' ? e.target.checked : e.target.value;
  };

  const _updateController = (attribute, e) => {
    updateController({ [attribute]: getEventValue(e) });
  };

  const _updateDisk = (uuid, attribute, e) => {
    updateDisk(uuid, { [attribute]: getEventValue(e) });
  };

  const disks = () => {
    return controllerVolumes.map((disk) => {
      return (
        <Disk
          key={disk.uuid}
          id={disk.uuid}
          updateDisk={_updateDisk.bind(this, disk.uuid)}
          removeDisk={removeDisk.bind(this, disk.uuid)}
          config={config}
          {...disk}
        />
      );
    });
  };

  return (
    <div className="controller-container">
    <div className="controller-header">
        <div className="control-label col-md-2 controller-selected-container">
          <label>{__('Create SCSI controller')}</label>
        </div>
        <div className="controller-type-container col-md-4">
          <Select value={controller.type}
                  onChange={_updateController.bind(this, 'type')}
                  options={config.controllerTypes} />
          <Button
            className="btn-add-disk"
            disabled={!addDiskEnabled}
            onClick={addDisk}
          >
            {__('Add volume')}
          </Button>
        </div>
        <div className="delete-controller-container">
          <Button className="btn-remove-controller" onClick={removeController}>
            {__('Delete Controller')}
          </Button>

        </div>
      </div>
      <div className="disks-container">
        {disks()}
      </div>
    </div>
  );
};

export default Controller;
