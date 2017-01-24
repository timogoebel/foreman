import React from 'react';
import { Button } from 'react-bootstrap';
import Disk from './disk';
import Select from '../../../../common/forms/Select';

const Controller = ({
  addDiskEnabled,
  addDisk,
  removeController,
  updateController,
  ControllerTypes,
  controller
}) => {
  const controllerUpdated = (attribute, e) => {
    const value = e.target.value;
    let attributes = {};

    attributes[attribute] = value;
    updateController(attributes);
  };

  const selectableTypes = () => {
    return Object.entries(ControllerTypes).map((attribute) => {
      return (<option key={attribute[0]} value={attribute[0]}>{attribute[1]}</option>);
    });
  };

  const disks = () => {
    return controller.disks.map((disk, index) => {
      debugger;
      return (<Disk
        key={index}
        id={index}
        datastores={controller.datastores}
        storagePods={controller.storage_pods}
        {...disk}
      />);
    });
  };

  return (
      <div>
       <div className="fields removable-item">
        <Select
          label={__('Create SCSI controller')}
          value={controller.type}
          onChange={controllerUpdated}
          options={selectableTypes()}
        />
         { disks() }
      </div>
        <div className="right">
          <Button
            /* .MaxDisksPerController */
            disabled={!addDiskEnabled}
            onClick={ addDisk }>
            {__('Add volume')}
          </Button>
          <Button
            onClick={ removeController }
            bsClass="btn btn-danger remove"
            bsStyle="danger">
            {__('Remove controller')}
          </Button>
        </div>
    </div>
    );
};

export default Controller;

  // componentDidMount() {
  //   if (this.props.disks.length === 0) { this.addDisk(this.props.position); }
  // }
