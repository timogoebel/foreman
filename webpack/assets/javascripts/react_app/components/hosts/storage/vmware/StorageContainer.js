import React from 'react';
import { Button } from 'react-bootstrap';
import Controller from './controller/';
import { connect } from 'react-redux';
import * as VmWareActions from '../../../../redux/actions/hosts/storage/vmware';
import { 
  MaxDisksPerController,
  ControllerTypes 
} from './StorageContainer.utils';

class StorageContainer extends React.Component {
  constructor(props) {
    super(props);
    // this.state = { controllers: VMStorageStore.getControllers() };
    // helpers.bindMethods(this, [
    //   'onChange', 'onError',
    //   'addController', 'removeController'
    // ]);
  }
  componentDidMount() {
    const { data, loadController } = this.props;

    loadController(data);
  }

  // onChange(event) {
  //   this.setState({ controllers: VMStorageStore.getControllers() });
  // }

  // addController(e = null) {
  //   VMStorageActions.addController({ defaults: this.props.data });
  // }

  // removeController(currentPosition, e) {
  //   VMStorageActions.removeController(currentPosition);
  // }

  // loadDefaultController() {
  //   if (this.state.controllers.length === 0) {
  //     this.addController();
  //   }
  // }

  controllers() {
    const { addDisk, removeController, updateController } = this.props;

    return this.props.controllers.map((controller, idx) => (
      <Controller key={ idx }
        controller={ controller }
        addDiskEnabled={ controller.disks.length < MaxDisksPerController }
        addDisk={ () => addDisk(idx) }
        removeController={ () => removeController(idx) }
        updateController={ (newValues) => updateController(idx, newValues) }
        ControllerTypes={ ControllerTypes }/>
    ));
  }

  format() {
    let data = { scsiControllers: [], volumes: [] };

    this.props.controllers.forEach(controller => {
      data.scsiControllers.push({
        key: controller.SCSIKey,
        type: controller.type
      });
      controller.disks.forEach(disk => {
        let attributes = {
          sizeGb: disk.size,
          storagePod: disk.storagePod,
          thin: disk.thinProvision,
          datastore: disk.dataStore,
          eagerZero: disk.eagerZero,
          controllerKey: controller.SCSIKey,
          name: disk.name
        };

        data.volumes.push(attributes);
      });
    });
    return JSON.stringify(data);
  }

  render() {
    const { disableAddBtn } = this.props;

    return (
      <div className="row">
        <fieldset id="storage_volumes">
          <legend>{__('Storage')}</legend>
          {this.controllers()}
        </fieldset>
        <div className="row fr">
          <div className="clearfix">
            <Button
              id="add-controller"
              onClick={this.addController}
              disabled={ disableAddBtn }>
              Add Controller
            </Button>
          </div>
        </div>
        <input
          value={this.format()}
          name="host[compute_attributes][scsi_controllers]"
          hidden={true}
          readOnly={true}
        />
        <code>
          JSON:
          {JSON.stringify(this.format())}
        </code>
      </div>
    );
  }
}

const mapDispatchToProps = state => {
  return {
    controllers: state.hosts.storage.vmware.controllers,
    disableAddBtn: true
  };
};

export default connect(mapDispatchToProps, VmWareActions)(StorageContainer);
