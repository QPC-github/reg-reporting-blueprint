#!/bin/bash

# Copyright 2022 The Reg Reporting Blueprint Authors

# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     https://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Root directory of the project
HOMELOAN_DIR=$(dirname $0)
ROOT_DIR=${HOMELOAN_DIR}/../../..

# Environment variables
echo -e "\n\nInitialise environment variables"
source ${ROOT_DIR}/environment-variables.sh

# Retrieve terraform config
echo -e "\n\nGet the terraform configuration"
pushd ${ROOT_DIR}/common_components/orchestration/infrastructure/
AIRFLOW_DAG_GCS=$(terraform output --raw airflow_dag_gcs_prefix)
AIRFLOW_UI=$(terraform output --raw airflow_uri)
echo -e "\tAIRFLOW_DAG_GCS: "${AIRFLOW_DAG_GCS}
echo -e "\tAIRFLOW_UI:      "${AIRFLOW_UI}
popd

# Load the data to GCS
echo -e "\n\nLoad the sample data for the Home Loan Delinquency example"
pushd data_load
./load_to_gcs.sh ../data/input
./load_to_gcs.sh ../data/expected
popd

# Create containerised app for data load
echo -e "\n\nCreate a containerised data load application"
pushd ${ROOT_DIR}
gcloud builds submit --config use_cases/examples/home_loan_delinquency/data_load/cloudbuild.yaml
popd

# Create containerised app for DBT transformation
echo -e "\n\nCreate a containerised data transformation application"
pushd ${ROOT_DIR}
gcloud builds submit --config use_cases/examples/home_loan_delinquency/dbt/cloudbuild.yaml
popd

# Submit the DAG to Composer
echo -e "\n\nSubmit the DAG to Composer"
pushd ${HOMELOAN_DIR}/deploy
gsutil cp run_homeloan_dag.py ${AIRFLOW_DAG_GCS}

echo -e "\tClick on the link to see progress: "${AIRFLOW_UI}
popd
