import React from 'react';
import {Button} from 'react-bootstrap';
import Controller from './controller/';
import {connect} from 'react-redux';
import * as VmWareActions from '../../../../redux/actions/hosts/storage/vmware';
import { MaxDisksPerController, getDiskModeTypes, MaxControllers } from './StorageContainer.consts';
import { controllersToJsonString } from './StorageContainer.utils';
import './StorageContainer.scss';

class StorageContainer extends React.Component {
  constructor(props) {
    super(props);
  }
  componentDidMount() {
    const {data, initController} = this.props;

    initController(data);
  }

  controllers(controllerTypes) {
    const {addDisk, updateController, removeDisk, updateDisk, removeController} = this.props;

    return this
      .props
      .controllers
      .map((controller, idx) => (<Controller
        key={idx}
        removeController={removeController.bind(this, idx)}
        controller={controller}
        addDiskEnabled={controller.disks.length < MaxDisksPerController}
        addDisk={addDisk.bind(this, idx)}
        updateDisk={updateDisk.bind(this, idx)}
        removeDisk={removeDisk.bind(this, idx)}
        updateController={updateController.bind(this, idx)}
        controllerTypes={controllerTypes}
        diskModeTypes={getDiskModeTypes()}/>));
  }

  render() {
    const {addController, data, controllers, controllerTypes} = this.props;
    const disableAddControllerBtn = controllers.length === MaxControllers;

    return (
      <div className="row vmware-storage-container">
        <div className="storage-header">
          <div className="col-md-2 storage-title">
            {__('Storage')}
          </div>
          <div className="col-md-10 storage-controller-buttons">
            <Button
              className="btn-add-controller"
              onClick={() => addController(data)}
              disabled={disableAddControllerBtn}
              bsStyle="primary">
              {__('Add Controller')}
            </Button>
          </div>
        </div>
        <div className="storage-body">
          {this.controllers(controllerTypes)}
          <input
            value={controllersToJsonString(controllers)}
            id="scsi_controller_hidden"
            name="host[compute_attributes][scsi_controllers]"
            type="hidden"/>
        </div>
      </div>
    );
  }
}

const mapDispatchToProps = state => {
  const {controllers, controllerTypes} = state.hosts.storage.vmware;

  return {controllers, controllerTypes};
};

export default connect(mapDispatchToProps, VmWareActions)(StorageContainer);
