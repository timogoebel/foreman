import React from 'react';

/* eslint-disable no-unused-vars */
import {storiesOf, action, linkTo, addDecorator} from '@kadira/storybook';
require('../assets/javascripts/bundle');
require('../../app/assets/javascripts/application');
import ChartBox from '../assets/javascripts/react_app/components/charts/ChartBox';
import ChartModal from '../assets/javascripts/react_app/components/charts/ChartModal';
import chartService from '../assets/javascripts/services/statisticsChartService';
import mockData from './data/charts/donutChartMockData';
import {simpleLoader} from '../assets/javascripts/react_app/components/common/Loader';
import PowerStatusInner
from '../assets/javascripts/react_app/components/hosts/powerStatus/powerStatusInner';
import Store from '../assets/javascripts/react_app/redux';
import StorageContainer from '../assets/javascripts/react_app/components/hosts/storage/vmware';

addDecorator(story => (
  <div className="ca" style={{
    textAlign: 'center'
  }}>
    {story()}
    <div id="targetChart"/>
  </div>
));

storiesOf('Charts', module).add('Loading', () => (<ChartBox
  config={{
  data: {
    columns: []
  }
}}
  noDataMsg={'No data here'}
  title="Title"
  status="PENDING"/>)).add('Without Data', () => (<ChartBox
  config={{
  data: {
    columns: []
  }
}}
  noDataMsg={'No data here'}
  title="Title"
  status="RESOLVED"/>)).add('With Error', () => (<ChartBox
  config={{
  data: {
    columns: []
  }
}}
  title="Title"
  noDataMsg={'No data here'}
  errorText="Ooops"
  status="ERROR"/>)).add('Donut Chart', () => (<ChartBox
  config={mockData.config}
  modalConfig={mockData.modalConfig}
  noDataMsg={mockData.noDataMsg}
  tip={mockData.tip}
  id={mockData.id}
  title={mockData.title}
  status="RESOLVED"/>)).add('Modal', () => {
  /*
     onHide={this.closeModal}
     onEnter={this.onEnter}
     */
  let show = true;

  function hide() {
    show = false;
  }

  return (<ChartModal
    show={show}
    onHide={hide}
    config={mockData.modalConfig}
    title={mockData.title}
    id={mockData + 'Modal'}
    setTitle={chartService.setTitle}/>);
});

storiesOf('Power Status', module).add(
  'Loading',
  () => <PowerStatusInner/>
).add(
  'ON',
  () => <PowerStatusInner state="on" title="on" statusText="On"/>
).add(
  'OFF',
  () => <PowerStatusInner state="off" title="off" statusText="Off"/>
).add(
  'N/A',
  () => <PowerStatusInner state="na"
                          statusText="No power support"
                          title="N/A"/>
).add(
  'Error',
  () => (<PowerStatusInner
  state="na"
  statusText="Exception error some where"
  error="someError"
  title="N/A"/>));

// External data from vmware machine...
const vmwareData = {
  'controller_types': [
    {
      VirtualBusLogicController: 'Bus Logic Parallel'
    }, {
      VirtualLsiLogicController: 'LSI Logic Parallel'
    }, {
      VirtualLsiLogicSASController: 'LSI Logic SAS'
    }, {
      ParaVirtualSCSIController: 'VMware Paravirtual'
    }
  ],
  'storage_pods': [
    {
      StorageCluster: 'StorageCluster (free: 1.15 TB, prov: 7.35 TB, total: 8.5 TB)'
    }, {
      StorageCluster22: 'StorageCluster22 (free: 15 TB, prov: 7 TB, total: 18 TB)'
    }
  ],
  datastores: [
    {
      'cfme-esx-55-01-local': 'cfme-esx-55-01-local (free: 614 GB, prov: 348 GB, total: 924 GB)'
    }, {
      'cfme-esx-55-03-local': 'cfme-esx-55-03-local (free: 886 GB, prov: 188 GB, total: 924 GB)'
    }, {
      'cfme-esx-55-04-local': 'cfme-esx-55-04-local (free: 104 GB, prov: 824 GB, total: 924 GB)'
    }, {
      'cfme-esx-55-na01a': 'cfme-esx-55-na01a (free: 548 GB, prov: 8.16 TB, total: 4 TB)'
    }
  ]
};

storiesOf('VM Storage', module).add('multiple controllers', () => {
  return <StorageContainer store={Store} data={vmwareData}/>;
});
