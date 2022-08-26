-- Copyright 2022 Google LLC

-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at

--     https://www.apache.org/licenses/LICENSE-2.0

-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.


-- Table B1 Summary Stock Loans below 10m, by property type
--
-- Provides a breakdown of loans by property type, as required by table B1

SELECT
    sub_property_sector,
    SUM(limit_value) AS limit_value
FROM
    {{ ref('loan_level_stock_below_10m') }}
GROUP BY
    1
