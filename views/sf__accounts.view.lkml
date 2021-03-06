view: snowflake_sf__accounts {
  extends: [sf__accounts]
  sql_table_name: SEGMENT.SALESFORCE.ACCOUNTS ;;
}

view: sf__accounts {
  extends: [sfbase__accounts]

  filter: created_date_condition {
    type: date
  }

  dimension: id {
    #X# extends:"account_id_c"
  }

  dimension: is_in_created_date_filter {
    type: yesno
    sql: {% condition created_date_condition %} ${created_date} {% endcondition %}
      ;;
  }

  measure: accounts_in_created_date_filter {
    type: count
    filters: {
      field: is_in_created_date_filter
      value: "yes"
    }
  }

  measure: percent_of_accounts {
    type: percent_of_total
    sql: ${count} ;;
  }

  measure: count_customers {
    type: count
    filters: {
      field: type
      value: "\"Customer\""
    }
    drill_fields: [detail*]
  }
}

view: total_active_node_count {
  derived_table: {
    explore_source: sf__opportunities {
      column: id { field: sf__accounts.id }
      column: name { field: sf__accounts.name }
      column: total_quantity { field: opportunity_products.total_quantity }
      column: node_type { field: opportunity_products.node_type }
      filters: {
        field: opportunity_products.end_date
        value: "after 1 days from now"
      }
      filters: {
        field: opportunity_products.node_type
        value: "-None"
      }
      filters: {
        field: opportunity_products.product_family
        value: "Subscription"
      }
      filters: {
        field: sf__opportunities.is_won
        value: "Yes"
      }
    }
  }
  parameter: bucket_size {
    type: number
    default_value: "5"
  }

  dimension: id {
    label: "Accounts ID"
    primary_key: yes
    description: "Unique SFDC ID for Account"
  }
  dimension: total_quantity {
    description: "Total quantity across included products"
    type: number
  }
  dimension: node_bucket{
    tiers: [0,5,10,15,20,25,50,75,100,150,200,250,300,350,500,1000]
    type: tier
    style: integer
    sql: ${total_quantity} ;;
  }
  dimension: dynamic_sort_field {
    sql:
      ${total_quantity} - mod(${total_quantity},{% parameter bucket_size %});;
    type: number
    hidden: yes
  }
  dimension: dynamic_node_bucket  {
    sql:
        ${total_quantity} - mod(${total_quantity},{% parameter bucket_size %}) ||
          '-' || ${total_quantity} - mod(${total_quantity},{% parameter bucket_size %}) + {% parameter bucket_size %}
      ;;
    order_by_field: dynamic_sort_field
  }
  dimension: name {
    type: string
  }
  measure: sum_quantity {
    type: sum
    sql: ${total_quantity} ;;
  }
  dimension: node_type {
    type: string
  }
  measure: total_customers {
    type: count_distinct
    sql: ${id} ;;
  }
}

view: sfbase__accounts {
  sql_table_name: salesforce.accounts ;;

  dimension: account_band {
    type: string
    description: "Standardized revenue band for this account"
    sql: ${TABLE}.account_band_c ;;
  }

  dimension: account_id {
    description: "Case-sensitive old-style SFDC account id.  Recommend using ID instead"
    hidden: no
    type: string
    sql: ${TABLE}.account_id_c ;;
  }

  dimension: account_next_step {
    type: string
    sql: ${TABLE}.account_next_step_c ;;
  }

  dimension: account_notes {
    type: string
    sql: ${TABLE}.account_notes_c ;;
  }

  dimension: account_record {
    type: string
    sql: ${TABLE}.account_record_c ;;
  }

  dimension: account_time_zone {
    type: string
    sql: ${TABLE}.account_time_zone_c ;;
  }

  dimension: acct_no {
    type: number
    sql: ${TABLE}.acct_no_c ;;
  }

  dimension: active_customer {
    type: yesno
    sql: ${TABLE}.active_customer_c ;;
    description: "Customer has active Enterprise entitlements"
  }

  dimension: annual_revenue {
    type: string
    sql: ${TABLE}.annual_revenue ;;
  }

  dimension: arr {
    label: "Annual Recurring Revenue"
    type: number
    sql: CAST(${TABLE}.arr_c as DECIMAL) ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0,\"K\";$0.00"
  }

  dimension: bfwd_state {
    type: string
    sql: ${TABLE}.bfwd_state_c ;;
  }

  dimension: billing_city {
    type: string
    sql: ${TABLE}.billing_city ;;
  }

  dimension: billing_country {
    type: string
    map_layer_name: countries
    sql: ${TABLE}.billing_country ;;
  }

  dimension: billing_country_code {
    type: string
    sql: ${TABLE}.billing_country_code ;;
  }

  dimension: billing_postal_code {
    type: string
    sql: ${TABLE}.billing_postal_code ;;
  }

  dimension: billing_state {
    type: string
    sql: ${TABLE}.billing_state ;;
  }

  dimension: billing_state_code {
    type: string
    sql: ${TABLE}.billing_state_code ;;
  }

  dimension: billing_street {
    type: string
    sql: ${TABLE}.billing_street ;;
  }

  dimension: cloudingo_agent_bas {
    type: number
    sql: ${TABLE}.cloudingo_agent_bas_c ;;
  }

  dimension: cloudingo_agent_sas {
    type: number
    sql: ${TABLE}.cloudingo_agent_sas_c ;;
  }

  dimension: company_overview {
    type: string
    sql: ${TABLE}.company_overview_c ;;
  }

  dimension: created_by_id {
    type: string
    sql: ${TABLE}.created_by_id ;;
  }

  dimension_group: created {
    type: time
    timeframes: [time, fiscal_month_num, fiscal_quarter, fiscal_quarter_of_year, fiscal_year, date, week, month]
    sql: ${TABLE}.created_date ;;
  }

  dimension: created_via_process_flow {
    type: yesno
    sql: ${TABLE}.created_via_process_flow_c ;;
  }

  dimension: currency_iso_code {
    type: string
    sql: ${TABLE}.currency_iso_code ;;
  }

  dimension_group: customer_acquisition_date {
    type: time
    timeframes: [time, fiscal_month_num, fiscal_quarter, fiscal_year, date, week, month]
    sql: ${TABLE}.customer_acquisition_date_c ;;
  }

  dimension_group: dalete_at_date {
    type: time
    timeframes: [time, fiscal_month_num, fiscal_quarter, fiscal_year, date, week, month]
    sql: ${TABLE}.dalete_at_date_c ;;
  }

  dimension: dandb_company_id {
    type: string
    sql: ${TABLE}.dandb_company_id ;;
  }

  dimension: de_company_region {
    type: string
    sql: ${TABLE}.de_company_region_c ;;
  }

  dimension: de_domain_region {
    type: string
    sql: ${TABLE}.de_domain_region_c ;;
  }

  dimension: delete_after_workflow {
    type: yesno
    sql: ${TABLE}.delete_after_workflow_c ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}.description ;;
  }

  dimension: domain {
    type: string
    sql: ${TABLE}.domain_c ;;
  }

  dimension: dscorgpkg_conflict {
    type: string
    sql: ${TABLE}.dscorgpkg_conflict_c ;;
  }

  dimension: dscorgpkg_deleted_from_discover_org {
    type: string
    sql: ${TABLE}.dscorgpkg_deleted_from_discover_org_c ;;
  }

  dimension: dscorgpkg_discover_org_id {
    type: string
    sql: ${TABLE}.dscorgpkg_discover_org_id_c ;;
  }

  dimension_group: dscorgpkg_discover_org_last_update {
    type: time
    timeframes: [time, fiscal_month_num, fiscal_quarter, fiscal_year, date, week, month]
    sql: ${TABLE}.dscorgpkg_discover_org_last_update_c ;;
  }

  dimension: dscorgpkg_discover_org_technologies {
    type: string
    sql: ${TABLE}.dscorgpkg_discover_org_technologies_c ;;
  }

  dimension: dscorgpkg_do_3_yr_employees_growth {
    type: string
    sql: ${TABLE}.dscorgpkg_do_3_yr_employees_growth_c ;;
  }

  dimension: dscorgpkg_do_3_yr_sales_growth {
    type: string
    sql: ${TABLE}.dscorgpkg_do_3_yr_sales_growth_c ;;
  }

  dimension: dscorgpkg_exclude_update {
    type: yesno
    sql: ${TABLE}.dscorgpkg_exclude_update_c ;;
  }

  dimension: dscorgpkg_external_discover_org_id {
    type: string
    sql: ${TABLE}.dscorgpkg_external_discover_org_id_c ;;
  }

  dimension: dscorgpkg_fiscal_year_end {
    type: string
    sql: ${TABLE}.dscorgpkg_fiscal_year_end_c ;;
  }

  dimension: dscorgpkg_fortune_rank {
    type: string
    sql: ${TABLE}.dscorgpkg_fortune_rank_c ;;
  }

  dimension: dscorgpkg_it_budget {
    type: number
    sql: ${TABLE}.dscorgpkg_it_budget_c ;;
  }

  dimension: dscorgpkg_it_employees {
    type: number
    sql: ${TABLE}.dscorgpkg_it_employees_c ;;
  }

  dimension: dscorgpkg_itorg_chart {
    type: string
    sql: ${TABLE}.dscorgpkg_itorg_chart_c ;;
  }

  dimension: dscorgpkg_lead_source {
    type: string
    sql: ${TABLE}.dscorgpkg_lead_source_c ;;
  }

  dimension: dscorgpkg_naics_codes {
    type: string
    sql: ${TABLE}.dscorgpkg_naics_codes_c ;;
  }

  dimension: dscorgpkg_ownership {
    type: string
    sql: ${TABLE}.dscorgpkg_ownership_c ;;
  }

  dimension: dscorgpkg_sic_codes {
    type: string
    sql: ${TABLE}.dscorgpkg_sic_codes_c ;;
  }

  dimension: duns_number {
    type: string
    sql: ${TABLE}.duns_number ;;
  }

  dimension: entitlement_created {
    type: yesno
    sql: ${TABLE}.entitlement_created_c ;;
  }

  dimension_group: first_click_to_accept_date {
    type: time
    timeframes: [time, fiscal_month_num, fiscal_quarter, fiscal_year, date, week, month]
    sql: ${TABLE}.first_click_to_accept_date_c ;;
  }

  dimension: fortune_10k_global {
    type: yesno
    sql: ${TABLE}.fortune_10_000_global_c ;;
    description: "is this a Global 10k target customer"
  }

  dimension: fortune_2000_global {
    type: yesno
    sql: ${TABLE}.fortune_2000_global_c ;;
    description: "is this a Global 2k target customer"
  }

  dimension: fortune_2000_global_rank {
    type: number
    sql: ${TABLE}.fortune_2000_global_rank_c ;;
  }

  dimension: geo {
    description: "Sales territory used for lead routing (e.g. AMER)"
    type: string
    sql: ${TABLE}.geo_c ;;
  }

  dimension: handle_with_care {
    type: yesno
    sql: ${TABLE}.handle_with_care_c ;;
  }

  dimension: handlewith_care {
    type: yesno
    sql: ${TABLE}.handlewith_care_c ;;
  }

  dimension: has_accredited_professionals {
    type: yesno
    sql: ${TABLE}.has_accredited_professionals_c ;;
  }

  dimension: has_activated_dvar_contract {
    type: yesno
    sql: ${TABLE}.has_activated_dvar_contract_c ;;
  }

  dimension: id {
    description: "Unique SFDC ID for Account"
    primary_key:  yes
    type: string
    sql: ${TABLE}.id ;;
    link: {
      label: "SFDC Account"
      url: "https://docker.my.salesforce.com/{{value}}"
      icon_url: "https://docker.my.salesforce.com/favicon.ico"
    }
  }

  dimension: industry {
    type: string
    sql: ${TABLE}.industry ;;
  }

  dimension: is_billing_info {
    type: yesno
    sql: ${TABLE}.is_billing_info_c ;;
  }

  dimension: is_customer_portal {
    type: yesno
    sql: ${TABLE}.is_customer_portal ;;
  }

  dimension: is_deleted {
    type: yesno
    sql: ${TABLE}.is_deleted ;;
  }

  dimension: is_partner {
    type: yesno
    sql: ${TABLE}.is_partner ;;
  }

  dimension: jigsaw_company_id {
    type: string
    sql: ${TABLE}.jigsaw_company_id ;;
  }

  dimension_group: last_activity {
    type: time
    timeframes: [time, fiscal_month_num, fiscal_quarter, fiscal_year, date, week, month]
    sql: ${TABLE}.last_activity_date ;;
  }

  dimension: last_modified_by_id {
    type: string
    sql: ${TABLE}.last_modified_by_id ;;
  }

  dimension_group: last_modified {
    type: time
    timeframes: [time, fiscal_month_num, fiscal_quarter, fiscal_year, date, week, month]
    sql: ${TABLE}.last_modified_date ;;
  }

  dimension_group: last_referenced {
    type: time
    timeframes: [time, fiscal_month_num, fiscal_quarter, fiscal_year, date, week, month]
    sql: ${TABLE}.last_referenced_date ;;
  }

  dimension_group: last_viewed {
    type: time
    timeframes: [time, fiscal_month_num, fiscal_quarter, fiscal_year, date, week, month]
    sql: ${TABLE}.last_viewed_date ;;
  }

  dimension: member {
    type: yesno
    sql: ${TABLE}.member_c ;;
  }

  dimension: naics_code {
    type: string
    sql: ${TABLE}.naics_code ;;
  }

  dimension: naics_desc {
    type: string
    sql: ${TABLE}.naics_desc ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}.name ;;
  }

  dimension: need_to_detele {
    type: yesno
    sql: ${TABLE}.need_to_detele_c ;;
  }

  dimension: netsuite_conn_account_balance {
    type: string
    sql: ${TABLE}.netsuite_conn_account_balance_c ;;
  }

  dimension: netsuite_conn_account_overdue_balance {
    type: string
    sql: ${TABLE}.netsuite_conn_account_overdue_balance_c ;;
  }

  dimension: netsuite_conn_celigo_update {
    type: yesno
    sql: ${TABLE}.netsuite_conn_celigo_update_c ;;
  }

  dimension: netsuite_conn_credit_hold {
    type: string
    sql: ${TABLE}.netsuite_conn_credit_hold_c ;;
  }

  dimension: netsuite_conn_credit_limit {
    type: string
    sql: ${TABLE}.netsuite_conn_credit_limit_c ;;
  }

  dimension: netsuite_conn_days_overdue {
    type: number
    sql: ${TABLE}.netsuite_conn_days_overdue_c ;;
  }

  dimension: netsuite_conn_net_suite_id {
    type: string
    sql: ${TABLE}.netsuite_conn_net_suite_id_c ;;
  }

  dimension: netsuite_conn_net_suite_sync_err {
    type: string
    sql: ${TABLE}.netsuite_conn_net_suite_sync_err_c ;;
  }

  dimension: netsuite_conn_push_to_net_suite {
    type: yesno
    sql: ${TABLE}.netsuite_conn_push_to_net_suite_c ;;
  }

  dimension: netsuite_conn_pushed_from_opportunity {
    type: yesno
    sql: ${TABLE}.netsuite_conn_pushed_from_opportunity_c ;;
  }

  dimension: netsuite_conn_pushed_from_quote {
    type: yesno
    sql: ${TABLE}.netsuite_conn_pushed_from_quote_c ;;
  }

  dimension: netsuite_conn_sync_in_progress {
    type: yesno
    sql: ${TABLE}.netsuite_conn_sync_in_progress_c ;;
  }

  dimension: netsuite_conn_unbilled_orders {
    type: string
    sql: ${TABLE}.netsuite_conn_unbilled_orders_c ;;
  }

  dimension: num_of_employees_with_both_certificates {
    type: number
    sql: ${TABLE}.num_of_employees_with_both_certificates_c ;;
  }

  dimension: num_of_employees_with_three_certificates {
    type: number
    sql: ${TABLE}.num_of_employees_with_three_certificates_c ;;
  }

  dimension: number_of_accredited_architects {
    type: number
    sql: ${TABLE}.number_of_accredited_architects_c ;;
  }

  dimension: number_of_accredited_consultants {
    type: number
    sql: ${TABLE}.number_of_accredited_consultants_c ;;
  }

  dimension: number_of_accredited_dsp {
    type: number
    sql: ${TABLE}.number_of_accredited_dsp_c ;;
  }

  dimension: number_of_accredited_dtsp {
    type: number
    sql: ${TABLE}.number_of_accredited_dtsp_c ;;
  }

  dimension: number_of_accredited_instructors {
    type: number
    sql: ${TABLE}.number_of_accredited_instructors_c ;;
  }

  dimension: number_of_active_entitlements {
    type: number
    sql: ${TABLE}.number_of_active_entitlements_c ;;
    description: "Number of active Enterprise contracts for the account"
  }

  dimension: number_of_developers {
    type: number
    sql: ${TABLE}.number_of_developers_c ;;
  }

  dimension: number_of_employees {
    type: number
    sql: ${TABLE}.number_of_employees ;;
  }

  dimension: of_business_from_the_education {
    type: string
    sql: ${TABLE}.of_business_from_the_education_c ;;
  }

  dimension: of_business_from_the_enterprise {
    type: string
    sql: ${TABLE}.of_business_from_the_enterprise_c ;;
  }

  dimension: of_business_from_the_federal {
    type: string
    sql: ${TABLE}.of_business_from_the_federal_c ;;
  }

  dimension: of_business_from_the_mid_mkt {
    type: string
    sql: ${TABLE}.of_business_from_the_mid_mkt_c ;;
  }

  dimension: of_business_from_the_smb_segm {
    type: string
    sql: ${TABLE}.of_business_from_the_smb_segm_c ;;
  }

  dimension: of_business_from_the_state_govt {
    type: string
    sql: ${TABLE}.of_business_from_the_state_govt_c ;;
  }

  dimension: of_revenues_from_consulting_services {
    type: string
    sql: ${TABLE}.of_revenues_from_consulting_services_c ;;
  }

  dimension: of_revenues_from_hardware_sales {
    type: string
    sql: ${TABLE}.of_revenues_from_hardware_sales_c ;;
  }

  dimension: of_revenues_from_post_sales_support {
    type: string
    sql: ${TABLE}.of_revenues_from_post_sales_support_c ;;
  }

  dimension: of_revenues_from_services_provider {
    type: string
    sql: ${TABLE}.of_revenues_from_services_provider_c ;;
  }

  dimension: of_revenues_from_software_sales {
    type: string
    sql: ${TABLE}.of_revenues_from_software_sales_c ;;
  }

  dimension: of_revenues_from_training {
    type: string
    sql: ${TABLE}.of_revenues_from_training_c ;;
  }

  dimension: opps {
    type: number
    sql: ${TABLE}.opps_c ;;
  }

  dimension: owner_id {
    type: string
    sql: ${TABLE}.owner_id ;;
  }

  dimension: parent_id {
    type: string
    sql: ${TABLE}.parent_id ;;
  }

  dimension: partner_category {
    type: string
    sql: ${TABLE}.partner_category_c ;;
  }

  dimension: partner_interest {
    type: string
    sql: ${TABLE}.partner_interest_c ;;
  }

  dimension: partner_program_status {
    type: string
    sql: ${TABLE}.partner_program_status_c ;;
  }

  dimension: partner_type {
    type: string
    sql: ${TABLE}.partner_type_c ;;
  }

  dimension: partners_agreement_approved {
    type: string
    sql: ${TABLE}.partners_agreement_approved_c ;;
  }

  dimension: apps_containerized_in_dev_build {
    type: number
    sql: ${TABLE}.apps_containerized_in_dev_build_c ;;
  }

  dimension: apps_in_prod {
    type: number
    sql: ${TABLE}.apps_in_prod_c ;;
  }

  dimension: are_you_using_any_other_container_tools {
    type: string
    sql: ${TABLE}.are_you_using_any_other_container_tools_c ;;
  }

  dimension: are_you_using_docker_engine_ee_basic {
    type: string
    sql: ${TABLE}.are_you_using_docker_engine_ee_basic_c ;;
  }

  dimension: are_you_using_docker_trusted_registry {
    type: string
    sql: ${TABLE}.are_you_using_docker_trusted_registry_c ;;
  }

  dimension: are_you_using_ucp {
    type: string
    sql: ${TABLE}.are_you_using_ucp_c ;;
  }

  dimension: target_apps_for_containerization {
    type: number
    sql: ${TABLE}.target_apps_for_containerization_c ;;
  }

  dimension: customer_health_status {
    type: string
    sql: ${TABLE}.customer_health_status_c ;;
  }

  dimension: customer_journey_phase {
    type: string
    sql: ${TABLE}.customer_journey_phase_c ;;
  }

  dimension: phone {
    type: string
    sql: ${TABLE}.phone ;;
  }

  dimension: photo_url {
    type: string
    sql: ${TABLE}.photo_url ;;
  }

  dimension: rating {
    type: string
    sql: ${TABLE}.rating ;;
  }

  dimension: recalculate_has_activated_dvarcontracts {
    type: yesno
    sql: ${TABLE}.recalculate_has_activated_dvarcontracts_c ;;
  }

  dimension_group: received {
    type: time
    timeframes: [time, fiscal_month_num, fiscal_quarter, fiscal_year, date, week, month]
    sql: ${TABLE}.received_at ;;
  }

  dimension: record_type_id {
    type: string
    sql: ${TABLE}.record_type_id ;;
  }

  dimension: record_type_id_18 {
    hidden: yes
    type: string
    sql: ${TABLE}.record_type_id_c ;;
  }

  dimension: recurly_account_code {
    type: string
    sql: ${TABLE}.recurly_account_code_c ;;
  }

  dimension: recurly_card_first_six_number {
    type: string
    sql: ${TABLE}.recurly_card_first_six_number_c ;;
  }

  dimension: recurly_card_last_four_number {
    type: string
    sql: ${TABLE}.recurly_card_last_four_number_c ;;
  }

  dimension: recurly_card_month {
    type: string
    sql: ${TABLE}.recurly_card_month_c ;;
  }

  dimension: recurly_card_type {
    type: string
    sql: ${TABLE}.recurly_card_type_c ;;
  }

  dimension: recurly_card_year {
    type: string
    sql: ${TABLE}.recurly_card_year_c ;;
  }

  dimension: recurly_closed {
    type: yesno
    sql: ${TABLE}.recurly_closed_c ;;
  }

  dimension: recurly_company {
    type: string
    sql: ${TABLE}.recurly_company_c ;;
  }

  dimension: recurly_county {
    type: string
    sql: ${TABLE}.recurly_county_c ;;
  }

  dimension: recurly_email {
    type: string
    sql: ${TABLE}.recurly_email_c ;;
  }

  dimension: recurly_first_name {
    type: string
    sql: ${TABLE}.recurly_first_name_c ;;
  }

  dimension: recurly_in_trial {
    type: yesno
    sql: ${TABLE}.recurly_in_trial_c ;;
  }

  dimension: recurly_ip_address_country {
    type: string
    sql: ${TABLE}.recurly_ip_address_country_c ;;
  }

  dimension: recurly_ip {
    type: string
    sql: ${TABLE}.recurly_ip_c ;;
  }

  dimension: recurly_last_name {
    type: string
    sql: ${TABLE}.recurly_last_name_c ;;
  }

  dimension: recurly_past_due {
    type: yesno
    sql: ${TABLE}.recurly_past_due_c ;;
  }

  dimension: recurly_phone {
    type: string
    sql: ${TABLE}.recurly_phone_c ;;
  }

  dimension: recurly_plan_code {
    type: string
    sql: ${TABLE}.recurly_plan_code_c ;;
  }

  dimension: recurly_plan_name {
    type: string
    sql: ${TABLE}.recurly_plan_name_c ;;
  }

  dimension: recurly_state {
    type: string
    sql: ${TABLE}.recurly_state_c ;;
  }

  dimension: recurly_subscriber {
    type: yesno
    sql: ${TABLE}.recurly_subscriber_c ;;
  }

  dimension_group: recurly_updated_at {
    type: time
    timeframes: [time, fiscal_month_num, fiscal_quarter, fiscal_year, date, week, month]
    sql: ${TABLE}.recurly_updated_at_c ;;
  }

  dimension: recurly_uuid {
    type: string
    sql: ${TABLE}.recurly_uuid_c ;;
  }

  dimension: region {
    description: "Sales territory used for lead routing (e.g. AMER-West)"
    type: string
    sql: ${TABLE}.region_c ;;
  }

  dimension: sales_account_classification {
    description: "Sales classification (e.g. Target and Focus accounts)"
    type: string
    sql: ${TABLE}.sales_account_classification_c ;;
  }

  dimension: service_region {
    type: string
    sql: ${TABLE}.service_region_c ;;
  }

  dimension: share_account_with_all {
    type: yesno
    sql: ${TABLE}.share_account_with_all_c ;;
  }

  dimension: shipping_city {
    type: string
    sql: ${TABLE}.shipping_city ;;
  }

  dimension: shipping_country {
    type: string
    sql: ${TABLE}.shipping_country ;;
  }

  dimension: shipping_country_code {
    type: string
    sql: ${TABLE}.shipping_country_code ;;
  }

  dimension: shipping_postal_code {
    type: string
    sql: ${TABLE}.shipping_postal_code ;;
  }

  dimension: shipping_state {
    type: string
    sql: ${TABLE}.shipping_state ;;
  }

  dimension: shipping_state_code {
    type: string
    sql: ${TABLE}.shipping_state_code ;;
  }

  dimension: shipping_street {
    type: string
    sql: ${TABLE}.shipping_street ;;
  }

  dimension: sub_region {
    description: "Sales territory used for lead routing (e.g. AMER-West-Northern California)"
    type: string
    sql: ${TABLE}.sub_region_c ;;
  }

  dimension_group: system_modstamp {
    type: time
    timeframes: [time, fiscal_month_num, fiscal_quarter, fiscal_year, date, week, month]
    sql: ${TABLE}.system_modstamp ;;
  }

  dimension: tam_account {
    label: "TAM Account"
    type: yesno
    sql: ${TABLE}.tam_account_c ;;
  }

  dimension: trm_account {
    label: "TRM Account"
    type: yesno
    sql: ${TABLE}.trm_account_c ;;
  }

  dimension: tam_type {
    label: "TAM Type"
    type: string
    sql: ${TABLE}.tam_type_c ;;
  }

  dimension: tam {
    type: string
    sql: ${TABLE}.tam_c ;;
  }

  dimension: territory {
    type: string
    sql: ${TABLE}.territory_c ;;
  }

  dimension: total_closed_amount {
    label: "Lifetime Total Spend"
    type: number
    sql: ${TABLE}.total_closed_amount_c ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0.00"
  }

  dimension: total_services_amount {
    label: "Lifetime Services Spend"
    type: number
    sql: ${TABLE}.total_services_amount_c ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0.00"
  }

  dimension: total_subscription_amount {
    label: "Lifetime Subscription Spend"
    type: number
    sql: ${TABLE}.total_subscription_amount_c ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0.00"
  }

  dimension: tradestyle {
    type: string
    sql: ${TABLE}.tradestyle ;;
  }

  dimension: type {
    type: string
    sql: ${TABLE}.type ;;
  }

  dimension: uuid {
    type: number
    value_format_name: id
    sql: ${TABLE}.uuid ;;
  }

  dimension_group: uuid_ts {
    type: time
    timeframes: [time, fiscal_month_num, fiscal_quarter, fiscal_year, date, week, month]
    sql: ${TABLE}.uuid_ts ;;
  }

  dimension: website {
    type: string
    sql: ${TABLE}.website ;;
  }

  dimension: year_started {
    type: string
    sql: ${TABLE}.year_started ;;
  }

  dimension: years_in_business {
    type: number
    sql: ${TABLE}.years_in_business_c ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: count_tam {
    type: sum
    sql: CASE WHEN ${tam_account} THEN 1 ELSE 0 END;;
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      id,
      name,
      owner.id,
      owner.name,
      geo,
      region,
      sub_region,
      cases.count,
      contacts.count,
      contracts.count,
      events.count,
      opportunities.count,
      tasks.count,
      users.count
    ]
  }
}
