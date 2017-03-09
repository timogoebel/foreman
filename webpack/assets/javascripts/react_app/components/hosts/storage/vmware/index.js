import React from 'react';
import {Button} from 'react-bootstrap';
import Controller from './controller/';
import {connect} from 'react-redux';
import * as VmWareActions from '../../../../redux/actions/hosts/storage/vmware';
import {
  MaxDisksPerController,
  ControllerTypes,
  MaxControllers,
  InitialSCSIKey
} from './StorageContainer.consts';
import './StorageContainer.scss';

class StorageContainer extends React.Component {
  constructor(props) {
    super(props);
  }
  componentDidMount() {
    const {data, initController} = this.props;

    initController(data);
  }

  controllers() {
    const {addDisk, updateController, removeDisk, updateDisk, removeController} = this.props;

    return this
      .props
      .controllers
      .map((controller, idx) => (<Controller
        key={idx}
        removeController={ removeController.bind(this, idx) }
        controller={controller}
        addDiskEnabled={controller.disks.length < MaxDisksPerController}
        addDisk={addDisk.bind(this, idx)}
        updateDisk={updateDisk.bind(this, idx)}
        removeDisk={removeDisk.bind(this, idx)}
        updateController={updateController.bind(this, idx)}
        ControllerTypes={ControllerTypes}/>));
  }

  format() {
    const data = this
      .props
      .controllers
      .reduce((curr, controller, idx) => Object.assign({}, curr, {
        scsiControllers: curr
          .scsiControllers
          .concat({
            key: InitialSCSIKey + idx,
            type: controller.type
          }),
        volumes: curr
          .volumes
          .concat(controller.disks.map(disk => ({
            sizeGb: disk.size,
            storagePod: disk.storagePod,
            thin: disk.thinProvision,
            datastore: disk.dataStore,
            eagerZero: disk.eagerZero,
            controllerKey: InitialSCSIKey + idx,
            name: disk.name
          })))
      }), {
        scsiControllers: [],
        volumes: []
      });

    return JSON.stringify(data);
  }

  render() {
    const {addController, data, controllers} = this.props;
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
          {this.controllers()}
          <input
            value={this.format()}
            id="scsi_controller_hidden"
            name="host[compute_attributes][scsi_controllers]"
            type="hidden"/>
        </div>
      </div>
    );
  }
}

const mapDispatchToProps = state => {
  return {controllers: state.hosts.storage.vmware.controllers};
};

export default connect(mapDispatchToProps, VmWareActions)(StorageContainer);
