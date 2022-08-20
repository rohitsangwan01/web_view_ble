/*jslint
        browser
*/
/*global
        atob, Event, console.log, window
*/
//  Copyright 2016-2017 Paul Theriault and David Park. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
// adapted from chrome app polyfill https://github.com/WebBluetoothCG/chrome-app-polyfill

(function () {
  "use strict";
  // console.log("Create BluetoothUUID");

  function canonicalUUID(uuidAlias) {
    // https://www.bluetooth.com/specifications/assigned-numbers/service-discovery
    uuidAlias >>>= 0; // Make sure the number is positive and 32 bits.
    let strAlias = `0000000${uuidAlias.toString(16)}`;
    strAlias = strAlias.substr(-8);
    // return `0000180f-0000-1000-8000-00805f9b34fb`;
    return strAlias + "-0000-1000-8000-00805f9b34fb";
  }

  const uuidRegex =
    /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
  const shortUUIDRegex = /^[0-9a-f]{4}([0-9a-f]{4})?$/i;

  let BluetoothUUID = {};
  BluetoothUUID.canonicalUUID = canonicalUUID;
  BluetoothUUID.service = {
    alert_notification: canonicalUUID(0x1811),
    automation_io: canonicalUUID(0x1815),
    battery_service: canonicalUUID(0x180f),
    blood_pressure: canonicalUUID(0x1810),
    body_composition: canonicalUUID(0x181b),
    bond_management: canonicalUUID(0x181e),
    continuous_glucose_monitoring: canonicalUUID(0x181f),
    current_time: canonicalUUID(0x1805),
    cycling_power: canonicalUUID(0x1818),
    cycling_speed_and_cadence: canonicalUUID(0x1816),
    device_information: canonicalUUID(0x180a),
    environmental_sensing: canonicalUUID(0x181a),
    generic_access: canonicalUUID(0x1800),
    generic_attribute: canonicalUUID(0x1801),
    glucose: canonicalUUID(0x1808),
    health_thermometer: canonicalUUID(0x1809),
    heart_rate: canonicalUUID(0x180d),
    human_interface_device: canonicalUUID(0x1812),
    immediate_alert: canonicalUUID(0x1802),
    indoor_positioning: canonicalUUID(0x1821),
    internet_protocol_support: canonicalUUID(0x1820),
    link_loss: canonicalUUID(0x1803),
    location_and_navigation: canonicalUUID(0x1819),
    next_dst_change: canonicalUUID(0x1807),
    phone_alert_status: canonicalUUID(0x180e),
    pulse_oximeter: canonicalUUID(0x1822),
    reference_time_update: canonicalUUID(0x1806),
    running_speed_and_cadence: canonicalUUID(0x1814),
    scan_parameters: canonicalUUID(0x1813),
    tx_power: canonicalUUID(0x1804),
    user_data: canonicalUUID(0x181c),
    weight_scale: canonicalUUID(0x181d),
  };

  BluetoothUUID.characteristic = {
    aerobic_heart_rate_lower_limit: canonicalUUID(0x2a7e),
    aerobic_heart_rate_upper_limit: canonicalUUID(0x2a84),
    aerobic_threshold: canonicalUUID(0x2a7f),
    age: canonicalUUID(0x2a80),
    aggregate: canonicalUUID(0x2a5a),
    alert_category_id: canonicalUUID(0x2a43),
    alert_category_id_bit_mask: canonicalUUID(0x2a42),
    alert_level: canonicalUUID(0x2a06),
    alert_notification_control_point: canonicalUUID(0x2a44),
    alert_status: canonicalUUID(0x2a3f),
    altitude: canonicalUUID(0x2ab3),
    anaerobic_heart_rate_lower_limit: canonicalUUID(0x2a81),
    anaerobic_heart_rate_upper_limit: canonicalUUID(0x2a82),
    anaerobic_threshold: canonicalUUID(0x2a83),
    analog: canonicalUUID(0x2a58),
    apparent_wind_direction: canonicalUUID(0x2a73),
    apparent_wind_speed: canonicalUUID(0x2a72),
    "gap.appearance": canonicalUUID(0x2a01),
    barometric_pressure_trend: canonicalUUID(0x2aa3),
    battery_level: canonicalUUID(0x2a19),
    blood_pressure_feature: canonicalUUID(0x2a49),
    blood_pressure_measurement: canonicalUUID(0x2a35),
    body_composition_feature: canonicalUUID(0x2a9b),
    body_composition_measurement: canonicalUUID(0x2a9c),
    body_sensor_location: canonicalUUID(0x2a38),
    bond_management_control_point: canonicalUUID(0x2aa4),
    bond_management_feature: canonicalUUID(0x2aa5),
    boot_keyboard_input_report: canonicalUUID(0x2a22),
    boot_keyboard_output_report: canonicalUUID(0x2a32),
    boot_mouse_input_report: canonicalUUID(0x2a33),
    "gap.central_address_resolution_support": canonicalUUID(0x2aa6),
    cgm_feature: canonicalUUID(0x2aa8),
    cgm_measurement: canonicalUUID(0x2aa7),
    cgm_session_run_time: canonicalUUID(0x2aab),
    cgm_session_start_time: canonicalUUID(0x2aaa),
    cgm_specific_ops_control_point: canonicalUUID(0x2aac),
    cgm_status: canonicalUUID(0x2aa9),
    csc_feature: canonicalUUID(0x2a5c),
    csc_measurement: canonicalUUID(0x2a5b),
    current_time: canonicalUUID(0x2a2b),
    cycling_power_control_point: canonicalUUID(0x2a66),
    cycling_power_feature: canonicalUUID(0x2a65),
    cycling_power_measurement: canonicalUUID(0x2a63),
    cycling_power_vector: canonicalUUID(0x2a64),
    database_change_increment: canonicalUUID(0x2a99),
    date_of_birth: canonicalUUID(0x2a85),
    date_of_threshold_assessment: canonicalUUID(0x2a86),
    date_time: canonicalUUID(0x2a08),
    day_date_time: canonicalUUID(0x2a0a),
    day_of_week: canonicalUUID(0x2a09),
    descriptor_value_changed: canonicalUUID(0x2a7d),
    "gap.device_name": canonicalUUID(0x2a00),
    dew_point: canonicalUUID(0x2a7b),
    digital: canonicalUUID(0x2a56),
    dst_offset: canonicalUUID(0x2a0d),
    elevation: canonicalUUID(0x2a6c),
    email_address: canonicalUUID(0x2a87),
    exact_time_256: canonicalUUID(0x2a0c),
    fat_burn_heart_rate_lower_limit: canonicalUUID(0x2a88),
    fat_burn_heart_rate_upper_limit: canonicalUUID(0x2a89),
    firmware_revision_string: canonicalUUID(0x2a26),
    first_name: canonicalUUID(0x2a8a),
    five_zone_heart_rate_limits: canonicalUUID(0x2a8b),
    floor_number: canonicalUUID(0x2ab2),
    gender: canonicalUUID(0x2a8c),
    glucose_feature: canonicalUUID(0x2a51),
    glucose_measurement: canonicalUUID(0x2a18),
    glucose_measurement_context: canonicalUUID(0x2a34),
    gust_factor: canonicalUUID(0x2a74),
    hardware_revision_string: canonicalUUID(0x2a27),
    heart_rate_control_point: canonicalUUID(0x2a39),
    heart_rate_max: canonicalUUID(0x2a8d),
    heart_rate_measurement: canonicalUUID(0x2a37),
    heat_index: canonicalUUID(0x2a7a),
    height: canonicalUUID(0x2a8e),
    hid_control_point: canonicalUUID(0x2a4c),
    hid_information: canonicalUUID(0x2a4a),
    hip_circumference: canonicalUUID(0x2a8f),
    humidity: canonicalUUID(0x2a6f),
    "ieee_11073-20601_regulatory_certification_data_list":
      canonicalUUID(0x2a2a),
    indoor_positioning_configuration: canonicalUUID(0x2aad),
    intermediate_blood_pressure: canonicalUUID(0x2a36),
    intermediate_temperature: canonicalUUID(0x2a1e),
    irradiance: canonicalUUID(0x2a77),
    language: canonicalUUID(0x2aa2),
    last_name: canonicalUUID(0x2a90),
    latitude: canonicalUUID(0x2aae),
    ln_control_point: canonicalUUID(0x2a6b),
    ln_feature: canonicalUUID(0x2a6a),
    "local_east_coordinate.xml": canonicalUUID(0x2ab1),
    local_north_coordinate: canonicalUUID(0x2ab0),
    local_time_information: canonicalUUID(0x2a0f),
    location_and_speed: canonicalUUID(0x2a67),
    location_name: canonicalUUID(0x2ab5),
    longitude: canonicalUUID(0x2aaf),
    magnetic_declination: canonicalUUID(0x2a2c),
    magnetic_flux_density_2D: canonicalUUID(0x2aa0),
    magnetic_flux_density_3D: canonicalUUID(0x2aa1),
    manufacturer_name_string: canonicalUUID(0x2a29),
    maximum_recommended_heart_rate: canonicalUUID(0x2a91),
    measurement_interval: canonicalUUID(0x2a21),
    model_number_string: canonicalUUID(0x2a24),
    navigation: canonicalUUID(0x2a68),
    new_alert: canonicalUUID(0x2a46),
    "gap.peripheral_preferred_connection_parameters": canonicalUUID(0x2a04),
    "gap.peripheral_privacy_flag": canonicalUUID(0x2a02),
    plx_continuous_measurement: canonicalUUID(0x2a5f),
    plx_features: canonicalUUID(0x2a60),
    plx_spot_check_measurement: canonicalUUID(0x2a5e),
    pnp_id: canonicalUUID(0x2a50),
    pollen_concentration: canonicalUUID(0x2a75),
    position_quality: canonicalUUID(0x2a69),
    pressure: canonicalUUID(0x2a6d),
    protocol_mode: canonicalUUID(0x2a4e),
    rainfall: canonicalUUID(0x2a78),
    "gap.reconnection_address": canonicalUUID(0x2a03),
    record_access_control_point: canonicalUUID(0x2a52),
    reference_time_information: canonicalUUID(0x2a14),
    report: canonicalUUID(0x2a4d),
    report_map: canonicalUUID(0x2a4b),
    resting_heart_rate: canonicalUUID(0x2a92),
    ringer_control_point: canonicalUUID(0x2a40),
    ringer_setting: canonicalUUID(0x2a41),
    rsc_feature: canonicalUUID(0x2a54),
    rsc_measurement: canonicalUUID(0x2a53),
    sc_control_point: canonicalUUID(0x2a55),
    scan_interval_window: canonicalUUID(0x2a4f),
    scan_refresh: canonicalUUID(0x2a31),
    sensor_location: canonicalUUID(0x2a5d),
    serial_number_string: canonicalUUID(0x2a25),
    "gatt.service_changed": canonicalUUID(0x2a05),
    software_revision_string: canonicalUUID(0x2a28),
    sport_type_for_aerobic_and_anaerobic_thresholds: canonicalUUID(0x2a93),
    supported_new_alert_category: canonicalUUID(0x2a47),
    supported_unread_alert_category: canonicalUUID(0x2a48),
    system_id: canonicalUUID(0x2a23),
    temperature: canonicalUUID(0x2a6e),
    temperature_measurement: canonicalUUID(0x2a1c),
    temperature_type: canonicalUUID(0x2a1d),
    three_zone_heart_rate_limits: canonicalUUID(0x2a94),
    time_accuracy: canonicalUUID(0x2a12),
    time_source: canonicalUUID(0x2a13),
    time_update_control_point: canonicalUUID(0x2a16),
    time_update_state: canonicalUUID(0x2a17),
    time_with_dst: canonicalUUID(0x2a11),
    time_zone: canonicalUUID(0x2a0e),
    true_wind_direction: canonicalUUID(0x2a71),
    true_wind_speed: canonicalUUID(0x2a70),
    two_zone_heart_rate_limit: canonicalUUID(0x2a95),
    tx_power_level: canonicalUUID(0x2a07),
    uncertainty: canonicalUUID(0x2ab4),
    unread_alert_status: canonicalUUID(0x2a45),
    user_control_point: canonicalUUID(0x2a9f),
    user_index: canonicalUUID(0x2a9a),
    uv_index: canonicalUUID(0x2a76),
    vo2_max: canonicalUUID(0x2a96),
    waist_circumference: canonicalUUID(0x2a97),
    weight: canonicalUUID(0x2a98),
    weight_measurement: canonicalUUID(0x2a9d),
    weight_scale_feature: canonicalUUID(0x2a9e),
    wind_chill: canonicalUUID(0x2a79),
  };

  BluetoothUUID.descriptor = {
    "gatt.characteristic_extended_properties": canonicalUUID(0x2900),
    "gatt.characteristic_user_description": canonicalUUID(0x2901),
    "gatt.client_characteristic_configuration": canonicalUUID(0x2902),
    "gatt.server_characteristic_configuration": canonicalUUID(0x2903),
    "gatt.characteristic_presentation_format": canonicalUUID(0x2904),
    "gatt.characteristic_aggregate_format": canonicalUUID(0x2905),
    valid_range: canonicalUUID(0x2906),
    external_report_reference: canonicalUUID(0x2907),
    report_reference: canonicalUUID(0x2908),
    value_trigger_setting: canonicalUUID(0x290a),
    es_configuration: canonicalUUID(0x290b),
    es_measurement: canonicalUUID(0x290c),
    es_trigger_setting: canonicalUUID(0x290d),
  };

  function resolveUUIDName(tableName) {
    let table = BluetoothUUID[tableName];
    return function (name) {
      if (typeof name === "number") {
        return canonicalUUID(name);
      }

      if (uuidRegex.test(name)) {
        //note native IOS bridges converts to uppercase since IOS seems to demand this.
        return name.toLowerCase();
      }

      if (table.hasOwnProperty(name)) {
        let data = table[name];
        console.log(`Got Table name : ${data}`);
        return data;
      }

      if (shortUUIDRegex.test(name)) {
        // this is not in the spec,
        // https://webbluetoothcg.github.io/web-bluetooth/#resolveuuidname
        // but iOS sends us short UUIDs and so we need to handle it.
        return canonicalUUID(parseInt(name, 16));
      }
      throw new TypeError(`${name} is not a known ${tableName} name.`);
    };
  }

  BluetoothUUID.getService = resolveUUIDName("service");
  BluetoothUUID.getCharacteristic = resolveUUIDName("characteristic");
  BluetoothUUID.getDescriptor = resolveUUIDName("descriptor");
  window.BluetoothUUID = BluetoothUUID;
  // console.log("BluetoothUUID imported");
})();
