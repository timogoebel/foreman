import React from 'react';
import {Button} from 'react-bootstrap';
import Controller from './controller/';
import {connect} from 'react-redux';
import { omit } from 'lodash';
import * as VmWareActions from '../../../../redux/actions/hosts/storage/vmware';
import {MaxDisksPerController, MaxControllers} from './StorageContainer.consts';
import './StorageContainer.scss';

class StorageContainer extends React.Component {
  constructor(props) {
    super(props);
  }
  componentDidMount() {
    const {
      data: {config, controllers, volumes},
      initController
    } = this.props;

    initController(config, controllers, volumes);
  }

  renderControllers(controllers) {
    const {
      addDisk,
      updateController,
      removeDisk,
      updateDisk,
      removeController,
      config,
      volumes
    } = this.props;

    return controllers.map((controller, idx) => {
      const controllerVolumes = volumes.filter(
				v => v.controller_key === controller.key
			);

      return (
        <Controller
          key={idx}
          removeController={removeController.bind(this, controller.key)}
          controller={controller}
					controllerVolumes={controllerVolumes}
          addDiskEnabled={controllerVolumes.length < MaxDisksPerController}
          addDisk={addDisk.bind(this, controller.key)}
          updateDisk={updateDisk}
          removeDisk={removeDisk}
          updateController={updateController.bind(this, idx)}
          config={config}
        />
      );
    });
  }

  render() {
    const {
      addController,
      controllers,
			volumes
    } = this.props;
    const disableAddControllerBtn = controllers.length === MaxControllers;
		const controllersToJsonString = (controllers, volumes) =>
			JSON.stringify({
			scsiControllers: controllers,
			volumes: volumes.map(v => omit(v, 'uuid'))
		});

    return (
      <div className="row vmware-storage-container">
        <div className="storage-header">
          <div className="col-md-2 storage-title">
            {__('Storage')}
          </div>
          <div className="col-md-10 storage-controller-buttons">
            <Button
              className="btn-add-controller"
              onClick={() => addController()}
              disabled={disableAddControllerBtn}
              bsStyle="primary"
            >
              {__('Add Controller')}
            </Button>
          </div>
        </div>
        <div className="storage-body">
          {this.renderControllers(controllers)}
          <input
            value={controllersToJsonString(controllers, volumes)}
            id="scsi_controller_hidden"
            name="host[compute_attributes][scsi_controllers]"
            type="hidden"
          />
					<code>
						{ controllersToJsonString(controllers, volumes) }
					</code>
        </div>
      </div>
    );
  }
}

const mapDispatchToProps = state => {
  const {
    controllers,
    config,
    volumes = []
  } = state.hosts.storage.vmware;

  return {controllers, volumes, config};
};

export default connect(mapDispatchToProps, VmWareActions)(StorageContainer);
