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
    removeController,
    controllerTypes,
    diskModeTypes
  }
) => {
  const getEventValue = e =>
    e.target.type === 'checkbox' ? e.target.checked : e.target.value;

  const _updateController = (attribute, e) => {
    updateController({ [attribute]: getEventValue(e) });
  };

  const _updateDisk = (diskIndex, attribute, e) => {
    updateDisk(diskIndex, { [attribute]: getEventValue(e) });
  };

  const disks = () => {
    return controller.disks.map((disk, index) => {
      return (
        <Disk
          key={index}
          id={index}
          updateDisk={_updateDisk.bind(this, index)}
          removeDisk={removeDisk.bind(this, index)}
          datastores={controller.datastores}
          storagePods={controller.storage_pods}
          diskModeTypes={diskModeTypes}
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
                  options={controllerTypes} />
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
