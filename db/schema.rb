# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2025_12_30_000002) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_stat_statements"
  enable_extension "pg_trgm"
  enable_extension "pgcrypto"
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "addon_subscriptions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "addon_type", null: false
    t.string "stripe_subscription_id"
    t.string "status", default: "active", null: false
    t.datetime "current_period_start", precision: nil
    t.datetime "current_period_end", precision: nil
    t.boolean "cancel_at_period_end", default: false
    t.jsonb "metadata", default: {}
    t.datetime "created_at", precision: nil, default: -> { "now()" }, null: false
    t.datetime "updated_at", precision: nil, default: -> { "now()" }, null: false
    t.integer "price_cents"
    t.datetime "canceled_at", precision: nil
    t.index ["addon_type"], name: "index_addon_subscriptions_on_addon_type"
    t.index ["status"], name: "index_addon_subscriptions_on_status"
    t.index ["stripe_subscription_id"], name: "index_addon_subscriptions_on_stripe_subscription_id", unique: true
    t.index ["user_id", "addon_type"], name: "index_addons_on_user_and_type", unique: true
  end

  create_table "alert_triggers", force: :cascade do |t|
    t.bigint "price_alert_id", null: false
    t.uuid "user_id", null: false
    t.string "commodity_code", null: false
    t.decimal "triggered_price", precision: 15, scale: 4, null: false
    t.string "alert_type", null: false
    t.json "metadata"
    t.boolean "notification_sent", default: false
    t.datetime "sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["notification_sent", "created_at"], name: "index_alert_triggers_on_notification_sent_and_created_at"
    t.index ["price_alert_id", "created_at"], name: "index_alert_triggers_on_price_alert_id_and_created_at"
    t.index ["price_alert_id"], name: "index_alert_triggers_on_price_alert_id"
    t.index ["user_id", "commodity_code", "created_at"], name: "idx_on_user_id_commodity_code_created_at_e01e7a5cb3"
    t.index ["user_id"], name: "index_alert_triggers_on_user_id"
  end

  create_table "api_keys", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.text "token"
    t.uuid "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "revoked_at", precision: nil
    t.datetime "limit_exceeded_at", precision: nil
    t.integer "api_request_count", default: 0
    t.index ["api_request_count"], name: "idx_api_keys_request_count"
    t.index ["token"], name: "idx_api_keys_token"
    t.index ["token"], name: "idx_api_keys_token_active", where: "(revoked_at IS NULL)"
  end

  create_table "api_requests", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id"
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "country", limit: 2
    t.string "city", limit: 100
    t.string "region", limit: 100
    t.string "region_code", limit: 10
    t.string "postal_code", limit: 20
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.string "timezone", limit: 50
    t.integer "metro_code"
    t.boolean "is_eu", default: false
    t.string "client_type", limit: 50
    t.string "sdk_language", limit: 20
    t.string "sdk_version", limit: 20
    t.string "client_platform", limit: 50
    t.string "client_platform_version", limit: 20
    t.string "client_device_type", limit: 30
    t.string "client_browser", limit: 50
    t.string "client_browser_version", limit: 20
    t.string "client_engine", limit: 50
    t.string "client_engine_version", limit: 20
    t.integer "bot_score"
    t.integer "threat_score"
    t.boolean "is_tor", default: false
    t.integer "asn"
    t.string "isp", limit: 100
    t.string "company_domain", limit: 100
    t.string "cf_ray", limit: 50
    t.string "session_id", limit: 100
    t.uuid "organization_id"
    t.string "pricing_test_group"
    t.decimal "adhoc_rate", precision: 8, scale: 6
    t.integer "response_status"
    t.decimal "response_time_ms", precision: 10, scale: 2
    t.index "((data ->> 'path'::text))", name: "index_api_requests_on_path_jsonb"
    t.index ["client_type"], name: "index_api_requests_on_client_type"
    t.index ["country", "created_at"], name: "index_api_requests_on_country_and_created_at"
    t.index ["created_at"], name: "index_api_requests_on_created_at"
    t.index ["organization_id", "created_at"], name: "index_api_requests_on_organization_id_and_created_at"
    t.index ["pricing_test_group", "created_at"], name: "index_api_requests_on_pricing_test_group_and_created_at"
    t.index ["response_status", "created_at"], name: "index_api_requests_on_response_status_and_created_at"
    t.index ["sdk_language"], name: "index_api_requests_on_sdk_language"
    t.index ["user_id", "created_at"], name: "idx_api_requests_user_analytics", order: { created_at: :desc }, where: "(user_id IS NOT NULL)"
    t.index ["user_id", "created_at"], name: "index_api_requests_on_user_id_and_created_at"
    t.index ["user_id", "response_status", "created_at"], name: "idx_api_requests_user_status_created"
  end

  create_table "api_requests_archive", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id"
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "country", limit: 2
    t.string "city", limit: 100
    t.string "region", limit: 100
    t.string "region_code", limit: 10
    t.string "postal_code", limit: 20
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.string "timezone", limit: 50
    t.integer "metro_code"
    t.boolean "is_eu", default: false
    t.string "client_type", limit: 50
    t.string "sdk_language", limit: 20
    t.string "sdk_version", limit: 20
    t.string "client_platform", limit: 50
    t.string "client_platform_version", limit: 20
    t.string "client_device_type", limit: 30
    t.string "client_browser", limit: 50
    t.string "client_browser_version", limit: 20
    t.string "client_engine", limit: 50
    t.string "client_engine_version", limit: 20
    t.integer "bot_score"
    t.integer "threat_score"
    t.boolean "is_tor", default: false
    t.integer "asn"
    t.string "isp", limit: 100
    t.string "company_domain", limit: 100
    t.string "cf_ray", limit: 50
    t.string "session_id", limit: 100
    t.uuid "organization_id"
    t.string "pricing_test_group"
    t.decimal "adhoc_rate", precision: 8, scale: 6
    t.index ["client_type"], name: "api_requests_archive_client_type_idx"
    t.index ["client_type"], name: "idx_archive_client_type"
    t.index ["country"], name: "api_requests_archive_country_idx"
    t.index ["country"], name: "idx_archive_country"
    t.index ["created_at"], name: "api_requests_archive_created_at_idx"
    t.index ["created_at"], name: "idx_archive_created_at"
    t.index ["organization_id"], name: "api_requests_archive_organization_id_idx"
    t.index ["organization_id"], name: "idx_archive_org_id"
    t.index ["pricing_test_group", "created_at"], name: "api_requests_archive_pricing_test_group_created_at_idx"
    t.index ["pricing_test_group"], name: "api_requests_archive_pricing_test_group_idx"
    t.index ["pricing_test_group"], name: "idx_archive_pricing_group"
    t.index ["sdk_language"], name: "api_requests_archive_sdk_language_idx"
    t.index ["user_id", "created_at"], name: "api_requests_archive_user_id_created_at_idx"
    t.index ["user_id", "created_at"], name: "api_requests_archive_user_id_created_at_idx1"
    t.index ["user_id", "created_at"], name: "api_requests_archive_user_id_created_at_idx2", order: { created_at: :desc }, where: "(user_id IS NOT NULL)"
    t.index ["user_id", "created_at"], name: "idx_archive_user_created"
    t.index ["user_id"], name: "api_requests_archive_user_id_idx"
    t.index ["user_id"], name: "idx_archive_user_id"
  end

  create_table "api_usage_violations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "violation_type", null: false
    t.jsonb "details", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_api_usage_violations_on_created_at"
    t.index ["user_id", "violation_type", "created_at"], name: "idx_violations_on_user_type_created"
    t.index ["user_id"], name: "index_api_usage_violations_on_user_id"
    t.index ["violation_type"], name: "index_api_usage_violations_on_violation_type"
  end

  create_table "billing_audit_exclusions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "customer_id", limit: 255, null: false
    t.text "reason", null: false
    t.datetime "excluded_at", precision: nil, default: -> { "now()" }, null: false
    t.string "excluded_by", limit: 255, default: "billing_audit_2024_12_24"

    t.unique_constraint ["customer_id"], name: "billing_audit_exclusions_customer_id_key"
  end

  create_table "billing_cards", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id"
    t.text "stripe_id"
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["stripe_id"], name: "index_billing_cards_on_stripe_id", unique: true
    t.index ["user_id"], name: "index_billing_cards_on_user_id"
  end

  create_table "billing_customers", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id"
    t.text "stripe_id"
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["stripe_id"], name: "index_billing_customers_on_stripe_id", unique: true
    t.index ["user_id"], name: "index_billing_customers_on_user_id"
  end

  create_table "billing_events", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id"
    t.text "stripe_id"
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "event_type"
    t.index ["stripe_id"], name: "index_billing_events_on_stripe_id", unique: true
    t.index ["user_id"], name: "index_billing_events_on_user_id"
  end

  create_table "billing_invoices", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id"
    t.text "stripe_id"
    t.text "customer_id"
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_billing_invoices_on_customer_id"
    t.index ["stripe_id"], name: "index_billing_invoices_on_stripe_id", unique: true
    t.index ["user_id"], name: "index_billing_invoices_on_user_id"
  end

  create_table "billing_payment_methods", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.text "stripe_id"
    t.text "customer_id"
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "billing_plans", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.text "stripe_id"
    t.integer "amount_cents"
    t.text "currency"
    t.text "interval"
    t.integer "interval_count"
    t.text "name"
    t.text "description"
    t.integer "trial_period_days"
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "metadata"
    t.string "lookup_key"
    t.index ["lookup_key"], name: "index_billing_plans_on_lookup_key"
    t.index ["stripe_id"], name: "index_billing_plans_on_stripe_id", unique: true
  end

  create_table "billing_subscriptions", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id"
    t.text "stripe_id"
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "customer_id"
    t.uuid "organization_id"
    t.index ["customer_id"], name: "index_billing_subscriptions_on_customer_id"
    t.index ["organization_id"], name: "index_billing_subscriptions_on_organization_id"
    t.index ["stripe_id"], name: "index_billing_subscriptions_on_stripe_id", unique: true
    t.index ["user_id"], name: "index_billing_subscriptions_on_user_id"
  end

  create_table "billing_subscriptions_backup_20241224", id: false, force: :cascade do |t|
    t.uuid "id"
    t.uuid "user_id"
    t.text "stripe_id"
    t.jsonb "data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "customer_id"
    t.text "user_email"
    t.timestamptz "backed_up_at"
  end

  create_table "chat_logs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "session_id", null: false
    t.string "user_email"
    t.string "user_plan"
    t.string "current_page"
    t.string "role", null: false
    t.text "content", null: false
    t.boolean "escalated", default: false
    t.jsonb "metadata", default: {}
    t.datetime "created_at", precision: nil, default: -> { "now()" }, null: false
    t.datetime "updated_at", precision: nil, default: -> { "now()" }, null: false
    t.index ["created_at"], name: "idx_chat_logs_created_at"
    t.index ["escalated"], name: "idx_chat_logs_escalated"
    t.index ["session_id"], name: "idx_chat_logs_session_id"
    t.index ["user_email"], name: "idx_chat_logs_user_email"
  end

  create_table "checkout_abandonments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id"
    t.string "email"
    t.string "session_id"
    t.string "price_id"
    t.integer "amount_cents"
    t.string "step"
    t.string "error_message"
    t.string "user_agent"
    t.string "ip_address"
    t.string "referrer"
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_checkout_abandonments_on_created_at"
    t.index ["email"], name: "index_checkout_abandonments_on_email"
    t.index ["session_id"], name: "index_checkout_abandonments_on_session_id"
    t.index ["step"], name: "index_checkout_abandonments_on_step"
    t.index ["user_id", "created_at"], name: "index_checkout_abandonments_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_checkout_abandonments_on_user_id"
  end

  create_table "credit_packs", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.integer "credits", null: false
    t.decimal "price", precision: 8, scale: 2, null: false
    t.string "stripe_price_id"
    t.boolean "active", default: true
    t.integer "sort_order", default: 0
    t.datetime "created_at", precision: nil, default: -> { "now()" }, null: false
    t.datetime "updated_at", precision: nil, default: -> { "now()" }, null: false
    t.index ["active"], name: "index_credit_packs_on_active"
    t.index ["sort_order"], name: "index_credit_packs_on_sort_order"
  end

  create_table "credit_purchases", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.integer "credit_pack_id", null: false
    t.integer "credits_purchased", null: false
    t.integer "credits_remaining", null: false
    t.decimal "amount_paid", precision: 8, scale: 2, null: false
    t.string "stripe_payment_intent_id"
    t.string "stripe_checkout_session_id"
    t.string "status", default: "pending", null: false
    t.datetime "purchased_at", precision: nil
    t.datetime "expires_at", precision: nil
    t.datetime "created_at", precision: nil, default: -> { "now()" }, null: false
    t.datetime "updated_at", precision: nil, default: -> { "now()" }, null: false
    t.index ["status", "expires_at"], name: "index_credit_purchases_on_status_and_expires_at"
    t.index ["stripe_checkout_session_id"], name: "index_credit_purchases_on_stripe_checkout_session_id", unique: true, where: "(stripe_checkout_session_id IS NOT NULL)"
    t.index ["stripe_payment_intent_id"], name: "index_credit_purchases_on_stripe_payment_intent_id", unique: true, where: "(stripe_payment_intent_id IS NOT NULL)"
    t.index ["user_id", "status"], name: "index_credit_purchases_on_user_id_and_status"
  end

  create_table "dark_data_drilling_productivities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "dark_data_report_id"
    t.date "report_month", null: false
    t.string "basin", null: false
    t.integer "duc_count"
    t.float "new_well_oil_per_rig"
    t.float "new_well_gas_per_rig"
    t.float "legacy_decline_rate"
    t.datetime "created_at", precision: nil, default: -> { "now()" }, null: false
    t.datetime "updated_at", precision: nil, default: -> { "now()" }, null: false
    t.index ["basin", "report_month"], name: "idx_productivity_basin_month"
    t.index ["dark_data_report_id"], name: "idx_dark_data_drilling_productivities_report_id"
  end

  create_table "dark_data_oil_inventories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "dark_data_report_id"
    t.date "report_date", null: false
    t.date "week_ending", null: false
    t.string "location", null: false
    t.string "product_type", null: false
    t.float "volume_million_barrels"
    t.float "week_over_week_change"
    t.float "five_year_avg"
    t.float "vs_five_year_avg_pct"
    t.datetime "created_at", precision: nil, default: -> { "now()" }, null: false
    t.datetime "updated_at", precision: nil, default: -> { "now()" }, null: false
    t.index ["dark_data_report_id"], name: "idx_dark_data_oil_inventories_report_id"
    t.index ["location", "report_date"], name: "idx_inventories_location_date"
    t.index ["product_type", "report_date"], name: "idx_inventories_product_date"
  end

  create_table "dark_data_opec_productions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "dark_data_report_id"
    t.date "report_month", null: false
    t.string "country", null: false
    t.string "source_type", null: false
    t.float "production_mbpd"
    t.float "month_over_month_change"
    t.float "quota_mbpd"
    t.float "compliance_pct"
    t.datetime "created_at", precision: nil, default: -> { "now()" }, null: false
    t.datetime "updated_at", precision: nil, default: -> { "now()" }, null: false
    t.index ["country", "report_month"], name: "idx_opec_country_month"
    t.index ["dark_data_report_id"], name: "idx_dark_data_opec_productions_report_id"
    t.index ["report_month"], name: "idx_dark_data_opec_productions_report_month"
  end

  create_table "dark_data_reports", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "source", null: false
    t.string "report_type", null: false
    t.date "report_date", null: false
    t.date "data_as_of"
    t.jsonb "raw_data", default: {}, null: false
    t.jsonb "parsed_data", default: {}, null: false
    t.jsonb "metadata", default: {}
    t.string "status", default: "pending"
    t.text "error_message"
    t.datetime "created_at", precision: nil, default: -> { "now()" }, null: false
    t.datetime "updated_at", precision: nil, default: -> { "now()" }, null: false
    t.index ["created_at"], name: "idx_dark_data_reports_created_at"
    t.index ["report_type"], name: "idx_dark_data_reports_report_type"
    t.index ["source", "report_date"], name: "idx_dark_data_reports_source_date", unique: true
    t.index ["status"], name: "idx_dark_data_reports_status"
  end

  create_table "dark_data_rig_counts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "dark_data_report_id"
    t.date "report_date", null: false
    t.string "region", null: false
    t.string "region_type", null: false
    t.string "rig_type"
    t.integer "count", null: false
    t.integer "week_over_week_change"
    t.float "year_over_year_change_pct"
    t.datetime "created_at", precision: nil, default: -> { "now()" }, null: false
    t.datetime "updated_at", precision: nil, default: -> { "now()" }, null: false
    t.index ["dark_data_report_id"], name: "idx_dark_data_rig_counts_report_id"
    t.index ["region", "report_date"], name: "idx_rig_counts_region_date"
    t.index ["region_type", "report_date"], name: "idx_rig_counts_type_date"
    t.index ["report_date"], name: "idx_dark_data_rig_counts_report_date"
  end

  create_table "data_quality_reports", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "code", null: false
    t.string "report_period", null: false
    t.string "grade", null: false
    t.jsonb "metrics", default: {}, null: false
    t.jsonb "statistics", default: {}, null: false
    t.datetime "generated_at", precision: nil, null: false
    t.datetime "created_at", precision: nil, default: -> { "now()" }, null: false
    t.datetime "updated_at", precision: nil, default: -> { "now()" }, null: false
    t.decimal "go_forward_score"
    t.string "go_forward_grade"
    t.index ["code", "report_period"], name: "index_data_quality_reports_on_code_and_report_period", unique: true
    t.index ["grade"], name: "index_data_quality_reports_on_grade"
    t.index ["report_period"], name: "index_data_quality_reports_on_report_period"
  end

  create_table "drilling_intelligences", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.decimal "value", precision: 10, scale: 2, null: false
    t.string "unit", null: false
    t.string "region", default: "United States", null: false
    t.string "source", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code", "region", "created_at"], name: "index_drilling_intelligences_on_code_and_region_and_created_at", unique: true
    t.index ["code"], name: "index_drilling_intelligences_on_code"
    t.index ["created_at"], name: "index_drilling_intelligences_on_created_at"
    t.index ["region"], name: "index_drilling_intelligences_on_region"
  end

  create_table "email_campaign_logs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "campaign_type", null: false
    t.integer "email_sequence", null: false
    t.string "email_name", null: false
    t.datetime "sent_at", null: false
    t.string "postmark_message_id"
    t.boolean "opened", default: false
    t.datetime "opened_at"
    t.boolean "clicked", default: false
    t.datetime "clicked_at"
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_marketing", default: false
    t.uuid "feedback_experiment_id"
    t.string "variant_name"
    t.boolean "is_experiment", default: false
    t.index ["campaign_type", "sent_at"], name: "index_email_campaign_logs_on_campaign_type_and_sent_at"
    t.index ["postmark_message_id"], name: "index_email_campaign_logs_on_postmark_message_id", unique: true
    t.index ["user_id", "campaign_type", "email_sequence", "email_name"], name: "idx_unique_campaign_sequence", unique: true
    t.index ["user_id", "campaign_type", "email_sequence"], name: "idx_prevent_duplicate_emails", unique: true
    t.index ["user_id", "campaign_type"], name: "index_email_campaign_logs_on_user_id_and_campaign_type"
    t.index ["user_id", "sent_at", "is_marketing"], name: "idx_on_user_id_sent_at_is_marketing_42d8e53bf0"
    t.index ["user_id"], name: "index_email_campaign_logs_on_user_id"
  end

  create_table "email_delivery_logs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id"
    t.string "mailer_class", null: false
    t.string "mailer_action", null: false
    t.string "recipient_email", null: false
    t.string "subject"
    t.string "email_type", null: false
    t.string "status", default: "pending", null: false
    t.string "postmark_message_id"
    t.text "postmark_error"
    t.datetime "sent_at", precision: nil
    t.datetime "delivered_at", precision: nil
    t.datetime "bounced_at", precision: nil
    t.datetime "opened_at", precision: nil
    t.datetime "clicked_at", precision: nil
    t.datetime "failed_at", precision: nil
    t.jsonb "metadata", default: {}
    t.datetime "created_at", precision: nil, default: -> { "now()" }, null: false
    t.datetime "updated_at", precision: nil, default: -> { "now()" }, null: false
    t.index ["created_at"], name: "index_email_delivery_logs_on_created_at"
    t.index ["email_type"], name: "index_email_delivery_logs_on_email_type"
    t.index ["mailer_action"], name: "index_email_delivery_logs_on_mailer_action"
    t.index ["mailer_class", "mailer_action"], name: "index_email_delivery_logs_on_mailer_class_and_action"
    t.index ["postmark_message_id"], name: "index_email_delivery_logs_on_postmark_message_id", unique: true
    t.index ["recipient_email"], name: "index_email_delivery_logs_on_recipient_email"
    t.index ["sent_at"], name: "index_email_delivery_logs_on_sent_at"
    t.index ["status", "failed_at"], name: "index_email_delivery_logs_on_failed_emails", where: "((status)::text = 'failed'::text)"
    t.index ["status"], name: "index_email_delivery_logs_on_status"
    t.index ["user_id"], name: "index_email_delivery_logs_on_user_id"
  end

  create_table "email_engagement_events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", limit: 255, null: false
    t.string "message_id", limit: 255, null: false
    t.string "event_type", limit: 50, null: false
    t.jsonb "metadata", default: {}
    t.datetime "occurred_at", precision: nil, null: false
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "updated_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.index ["email", "event_type"], name: "idx_email_engagement_events_email_type"
    t.index ["email", "occurred_at"], name: "idx_email_engagement_events_email_occurred"
    t.index ["email"], name: "idx_email_engagement_events_email"
    t.index ["event_type"], name: "idx_email_engagement_events_event_type"
    t.index ["message_id"], name: "idx_email_engagement_events_message_id"
    t.index ["occurred_at"], name: "idx_email_engagement_events_occurred_at"
  end

  create_table "email_suppression_lists", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", null: false
    t.string "reason", null: false
    t.jsonb "metadata", default: {}
    t.datetime "suppressed_at", precision: nil, null: false
    t.boolean "active", default: true, null: false
    t.datetime "unsuppressed_at", precision: nil
    t.uuid "unsuppressed_by"
    t.text "unsuppress_reason"
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["email", "active"], name: "index_email_suppression_lists_on_email_and_active"
    t.index ["email"], name: "index_email_suppression_lists_on_email", unique: true
    t.index ["suppressed_at"], name: "index_email_suppression_lists_on_suppressed_at"
  end

  create_table "entities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "canonical_name", limit: 500, null: false
    t.string "legal_name", limit: 500
    t.string "normalized_name", limit: 500
    t.string "entity_type", limit: 50
    t.string "status", limit: 50
    t.string "state", limit: 2
    t.string "jurisdiction", limit: 100
    t.date "formation_date"
    t.date "dissolution_date"
    t.jsonb "registered_agent", default: {}
    t.jsonb "principal_address", default: {}
    t.jsonb "mailing_address", default: {}
    t.string "source", limit: 50, null: false
    t.string "source_id", limit: 100
    t.jsonb "raw_data", default: {}
    t.decimal "confidence_score", precision: 3, scale: 2
    t.datetime "last_verified_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["entity_type"], name: "index_entities_on_entity_type"
    t.index ["formation_date"], name: "index_entities_on_formation_date"
    t.index ["last_verified_at"], name: "index_entities_on_last_verified_at"
    t.index ["normalized_name"], name: "index_entities_on_normalized_name", opclass: :gin_trgm_ops, using: :gin
    t.index ["source", "source_id"], name: "index_entities_on_source_and_source_id", unique: true
    t.index ["source"], name: "index_entities_on_source"
    t.index ["state"], name: "index_entities_on_state"
    t.index ["status"], name: "index_entities_on_status"
  end

  create_table "entity_identifiers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "entity_id", null: false
    t.string "identifier_type", limit: 50, null: false
    t.string "identifier_value", limit: 100, null: false
    t.boolean "verified", default: false
    t.string "source", limit: 50
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["entity_id", "identifier_type"], name: "index_entity_identifiers_on_entity_id_and_identifier_type", unique: true
    t.index ["entity_id"], name: "index_entity_identifiers_on_entity_id"
    t.index ["identifier_type", "identifier_value"], name: "idx_on_identifier_type_identifier_value_2c0efae044"
  end

  create_table "external_webhook_events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "provider", null: false
    t.string "event_type"
    t.string "event_id"
    t.string "status", default: "pending"
    t.jsonb "payload"
    t.jsonb "response"
    t.string "error_message"
    t.datetime "processed_at"
    t.integer "retry_count", default: 0
    t.string "signature_status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_external_webhook_events_on_event_id"
    t.index ["provider", "created_at"], name: "index_external_webhook_events_on_provider_and_created_at"
    t.index ["provider"], name: "index_external_webhook_events_on_provider"
    t.index ["status", "provider"], name: "index_external_webhook_events_on_status_and_provider"
    t.index ["status"], name: "index_external_webhook_events_on_status"
  end

  create_table "feature_flags", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.boolean "enabled", default: false, null: false
    t.integer "percentage", default: 0, null: false
    t.text "whitelist_emails", array: true
    t.jsonb "metadata", default: {}
    t.datetime "created_at", precision: nil, default: -> { "now()" }
    t.datetime "updated_at", precision: nil, default: -> { "now()" }
    t.index ["enabled"], name: "index_feature_flags_on_enabled"
    t.index ["name"], name: "index_feature_flags_on_name"
    t.check_constraint "percentage >= 0 AND percentage <= 100", name: "feature_flags_percentage_check"
    t.unique_constraint ["name"], name: "feature_flags_name_key"
  end

  create_table "feedback_experiments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "campaign_type", null: false
    t.string "status", default: "draft", null: false
    t.string "target_segment", null: false
    t.text "hypothesis"
    t.text "description"
    t.jsonb "config", default: {}, null: false
    t.integer "total_variants", default: 2, null: false
    t.integer "emails_sent", default: 0
    t.integer "total_opens", default: 0
    t.integer "total_replies", default: 0
    t.integer "total_conversions", default: 0
    t.boolean "has_significant_winner", default: false
    t.string "winning_variant"
    t.float "confidence_level", default: 0.0
    t.datetime "started_at", precision: nil
    t.datetime "completed_at", precision: nil
    t.integer "daily_send_limit", default: 50
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }, null: false
  end

  create_table "feedback_responses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "feedback_experiment_id", null: false
    t.uuid "email_campaign_log_id"
    t.text "raw_response", null: false
    t.string "variant_name", null: false
    t.string "primary_category"
    t.float "sentiment_score"
    t.text "key_pain_points", array: true
    t.text "feature_requests", array: true
    t.jsonb "ai_analysis", default: {}
    t.boolean "is_actionable", default: false
    t.integer "priority", default: 5
    t.boolean "followed_up", default: false
    t.uuid "followed_up_by"
    t.datetime "followed_up_at", precision: nil
    t.text "follow_up_notes"
    t.boolean "converted_to_paid", default: false
    t.datetime "converted_at", precision: nil
    t.decimal "conversion_revenue", precision: 10, scale: 2
    t.integer "days_to_conversion"
    t.datetime "responded_at", precision: nil, null: false
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }, null: false
  end

  create_table "futures_daily_summaries", force: :cascade do |t|
    t.string "code", null: false
    t.date "trading_date", null: false
    t.decimal "open_price", precision: 10, scale: 2
    t.datetime "open_captured_at"
    t.decimal "close_price", precision: 10, scale: 2
    t.datetime "close_captured_at"
    t.decimal "high_price", precision: 10, scale: 2
    t.decimal "low_price", precision: 10, scale: 2
    t.integer "daily_volume"
    t.decimal "daily_change_percent", precision: 8, scale: 4
    t.decimal "settlement_price", precision: 10, scale: 2
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["code", "trading_date"], name: "idx_futures_daily_summaries_code_date", unique: true
    t.index ["code"], name: "idx_futures_daily_summaries_code"
    t.index ["trading_date", "code"], name: "index_futures_daily_summaries_on_trading_date_and_code"
    t.index ["trading_date", "open_price", "close_price"], name: "idx_futures_summaries_complete_data", where: "((open_price IS NOT NULL) AND (close_price IS NOT NULL))"
    t.index ["trading_date"], name: "idx_futures_daily_summaries_trading_date"
  end

  create_table "in_app_notifications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "notification_type", null: false
    t.string "title", null: false
    t.text "message", null: false
    t.string "cta_text"
    t.string "cta_url"
    t.datetime "read_at"
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["notification_type"], name: "index_in_app_notifications_on_notification_type"
    t.index ["read_at"], name: "index_in_app_notifications_on_read_at"
    t.index ["user_id", "notification_type", "created_at"], name: "idx_notifications_user_type_created"
    t.index ["user_id", "read_at"], name: "index_in_app_notifications_on_user_id_and_read_at"
    t.index ["user_id"], name: "index_in_app_notifications_on_user_id"
  end

  create_table "leads", id: :serial, force: :cascade do |t|
    t.string "feature", null: false
    t.string "name", null: false
    t.string "email", null: false
    t.string "company"
    t.text "use_case"
    t.string "ip_address"
    t.string "user_agent"
    t.string "source", default: "website"
    t.datetime "created_at", precision: nil, default: -> { "now()" }, null: false
    t.datetime "updated_at", precision: nil, default: -> { "now()" }, null: false
    t.index ["created_at"], name: "index_leads_on_created_at"
    t.index ["email"], name: "index_leads_on_email"
    t.index ["feature"], name: "index_leads_on_feature"
  end

  create_table "marine_fuel_ports", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.string "country"
    t.string "region"
    t.decimal "latitude", precision: 10, scale: 8
    t.decimal "longitude", precision: 11, scale: 8
    t.boolean "major_port", default: false
    t.boolean "active", default: true
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_marine_fuel_ports_on_active"
    t.index ["code"], name: "index_marine_fuel_ports_on_code", unique: true
    t.index ["country", "region"], name: "index_marine_fuel_ports_on_country_and_region"
    t.index ["major_port"], name: "index_marine_fuel_ports_on_major_port"
  end

  create_table "natural_gas_storages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.decimal "working_gas_bcf", precision: 8, scale: 1, null: false
    t.decimal "week_change_bcf", precision: 6, scale: 1
    t.decimal "year_ago_bcf", precision: 8, scale: 1
    t.decimal "five_year_avg_bcf", precision: 8, scale: 1
    t.date "report_date", null: false
    t.string "region", default: "United States", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_natural_gas_storages_on_created_at"
    t.index ["region"], name: "index_natural_gas_storages_on_region"
    t.index ["report_date", "region"], name: "index_natural_gas_storages_on_report_date_and_region", unique: true
    t.index ["report_date"], name: "index_natural_gas_storages_on_report_date"
  end

  create_table "notification_preferences", force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "notification_type", null: false
    t.boolean "email_enabled", default: true
    t.boolean "sms_enabled", default: false
    t.boolean "whatsapp_enabled", default: false
    t.boolean "push_enabled", default: false
    t.jsonb "settings", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "notification_type"], name: "idx_on_user_id_notification_type_2ab4363e9b", unique: true
  end

  create_table "organization_invitations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "organization_id", null: false
    t.string "email", null: false
    t.string "token", null: false
    t.integer "role", default: 0, null: false
    t.datetime "expires_at", null: false
    t.datetime "accepted_at"
    t.uuid "invited_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_organization_invitations_on_expires_at"
    t.index ["invited_by_id"], name: "index_organization_invitations_on_invited_by_id"
    t.index ["organization_id", "email"], name: "index_organization_invitations_on_organization_id_and_email", unique: true
    t.index ["organization_id"], name: "index_organization_invitations_on_organization_id"
    t.index ["token"], name: "index_organization_invitations_on_token", unique: true
  end

  create_table "organization_members", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "organization_id", null: false
    t.uuid "user_id", null: false
    t.integer "role", default: 0, null: false
    t.datetime "invited_at"
    t.datetime "accepted_at"
    t.string "invitation_token"
    t.datetime "invitation_expires_at"
    t.jsonb "permissions", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invitation_token"], name: "index_organization_members_on_invitation_token", unique: true
    t.index ["organization_id", "user_id"], name: "index_organization_members_on_organization_id_and_user_id", unique: true
    t.index ["organization_id"], name: "index_organization_members_on_organization_id"
    t.index ["role"], name: "index_organization_members_on_role"
    t.index ["user_id"], name: "index_organization_members_on_user_id"
  end

  create_table "organizations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.uuid "owner_user_id", null: false
    t.string "stripe_customer_id"
    t.integer "seat_count", default: 1, null: false
    t.integer "used_seats", default: 0, null: false
    t.string "billing_email"
    t.jsonb "settings", default: {}
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "monthly_request_limit", default: 0, null: false
    t.string "slug"
    t.text "description"
    t.jsonb "metadata", default: {}, null: false
    t.index ["active"], name: "index_organizations_on_active"
    t.index ["name"], name: "index_organizations_on_name"
    t.index ["owner_user_id"], name: "index_organizations_on_owner_user_id"
    t.index ["slug"], name: "index_organizations_on_slug", unique: true
    t.index ["stripe_customer_id"], name: "index_organizations_on_stripe_customer_id", unique: true
  end

  create_table "phone_verifications", force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "phone_number", null: false
    t.string "phone_country_code", null: false
    t.string "verification_code"
    t.string "status", default: "pending"
    t.integer "attempts", default: 0
    t.datetime "verified_at"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["phone_number", "phone_country_code"], name: "idx_on_phone_number_phone_country_code_e54e96ba71"
    t.index ["user_id", "status"], name: "index_phone_verifications_on_user_id_and_status"
  end

  create_table "ppp_fraud_checks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "country_code", limit: 2, null: false
    t.integer "risk_score", null: false
    t.jsonb "flags", default: [], null: false
    t.string "recommended_action", limit: 255, null: false
    t.text "reason"
    t.datetime "created_at", precision: nil, default: -> { "now()" }, null: false
    t.datetime "updated_at", precision: nil, default: -> { "now()" }, null: false
    t.index ["recommended_action"], name: "index_ppp_fraud_checks_on_recommended_action"
    t.index ["risk_score"], name: "index_ppp_fraud_checks_on_risk_score"
    t.index ["user_id", "created_at"], name: "index_ppp_fraud_checks_on_user_id_and_created_at"
  end

  create_table "ppp_verification_signals", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "country_code", limit: 2, null: false
    t.integer "confidence_score", null: false
    t.jsonb "signals", default: [], null: false
    t.decimal "multiplier", precision: 4, scale: 2, null: false
    t.datetime "created_at", precision: nil, default: -> { "now()" }, null: false
    t.datetime "updated_at", precision: nil, default: -> { "now()" }, null: false
    t.index ["country_code"], name: "index_ppp_verification_signals_on_country_code"
    t.index ["user_id", "created_at"], name: "index_ppp_verification_signals_on_user_id_and_created_at"
  end

  create_table "price_alerts", force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "commodity_code", null: false
    t.string "alert_type"
    t.decimal "threshold_value", precision: 15, scale: 4
    t.string "threshold_direction"
    t.string "volatility_period"
    t.decimal "volatility_percentage", precision: 8, scale: 4
    t.boolean "active", default: true
    t.datetime "last_triggered_at"
    t.integer "trigger_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "condition_operator"
    t.decimal "condition_value", precision: 10, scale: 2
    t.jsonb "metadata", default: {}
    t.string "webhook_url", limit: 2048
    t.boolean "enabled", default: true, null: false
    t.integer "cooldown_minutes", default: 60, null: false
    t.string "analytics_type"
    t.jsonb "analytics_config", default: {}
    t.integer "analytics_period", default: 30
    t.index ["alert_type", "active"], name: "index_price_alerts_on_alert_type_and_active"
    t.index ["analytics_type"], name: "index_price_alerts_on_analytics_type", where: "(analytics_type IS NOT NULL)"
    t.index ["commodity_code", "active"], name: "index_price_alerts_on_commodity_code_and_active"
    t.index ["enabled", "last_triggered_at"], name: "index_price_alerts_on_enabled_and_last_triggered_at"
    t.index ["enabled"], name: "index_price_alerts_on_enabled"
    t.index ["user_id", "commodity_code"], name: "index_price_alerts_on_user_id_and_commodity_code"
    t.index ["user_id"], name: "index_price_alerts_on_user_id"
  end

  create_table "price_fixes_backup_20241227", id: false, force: :cascade do |t|
    t.uuid "id"
    t.integer "value_units"
    t.text "code"
    t.text "currency"
    t.text "source"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "type_name"
  end

  create_table "prices", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.integer "value_units"
    t.text "code"
    t.text "currency"
    t.text "source"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "type_name", default: "spot_price"
    t.string "data_source", default: "realtime"
    t.jsonb "original_data", default: {}
    t.string "port_code", limit: 3
    t.string "port_name", limit: 100
    t.integer "supplier_count"
    t.string "availability", limit: 20, default: "immediate"
    t.jsonb "metadata", default: {}
    t.string "name"
    t.string "units"
    t.index "date(created_at), code, type_name", name: "idx_prices_date_code_type"
    t.index ["code", "created_at", "value_units"], name: "idx_prices_brent_futures_historical", where: "((code ~~ 'BRENT_FUTURES_%'::text) AND (value_units IS NOT NULL))"
    t.index ["code", "created_at"], name: "idx_prices_code_created_spot", order: { created_at: :desc }, where: "(type_name = 'spot_price'::text)"
    t.index ["code", "created_at"], name: "idx_prices_daily_avg_code_created", order: { created_at: :desc }, where: "(type_name = 'daily_average_price'::text)"
    t.index ["code", "created_at"], name: "idx_prices_spot_code_created", order: { created_at: :desc }, where: "(type_name = 'spot_price'::text)"
    t.index ["code", "created_at"], name: "index_prices_on_code_and_created_at"
    t.index ["code", "created_at"], name: "index_prices_on_code_and_created_at_desc", order: { created_at: :desc }
    t.index ["code", "created_at"], name: "index_prices_on_storage_code_and_created_at", unique: true, where: "(code ~~ '%_STORAGE%'::text)"
    t.index ["code", "id"], name: "idx_prices_code_id"
    t.index ["code", "type_name", "created_at"], name: "idx_prices_code_type_created", order: { created_at: :desc }
    t.index ["code", "type_name", "created_at"], name: "idx_prices_latest_optimized", order: { created_at: :desc }
    t.index ["code"], name: "index_prices_on_code"
    t.index ["created_at", "code", "type_name"], name: "idx_prices_created_code_type", order: { created_at: :desc }
    t.index ["created_at", "value_units"], name: "idx_prices_created_value_units", where: "(value_units IS NOT NULL)"
    t.index ["created_at"], name: "idx_prices_brent_spot_latest", order: :desc, where: "((code = 'BRENT_CRUDE_USD'::text) AND (type_name = 'spot_price'::text))"
    t.index ["created_at"], name: "index_prices_on_created_at"
    t.index ["data_source"], name: "index_prices_on_data_source"
    t.index ["metadata"], name: "index_prices_on_metadata", using: :gin
    t.index ["port_code", "code", "created_at"], name: "idx_prices_port_fuel_time"
    t.index ["port_code"], name: "idx_prices_port"
    t.index ["source"], name: "index_prices_on_source"
    t.index ["type_name", "code", "source", "created_at"], name: "idx_prices_composite", order: { created_at: :desc }
    t.index ["type_name", "created_at"], name: "idx_prices_type_created", order: { created_at: :desc }
    t.index ["type_name"], name: "idx_prices_type_name"
    t.index ["type_name"], name: "index_prices_on_type_name"
  end

  create_table "prices_coal_backup_20251218", id: false, force: :cascade do |t|
    t.uuid "id"
    t.integer "value_units"
    t.text "code"
    t.text "currency"
    t.text "source"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "type_name"
    t.string "data_source"
    t.jsonb "original_data"
    t.string "port_code", limit: 3
    t.string "port_name", limit: 100
    t.integer "supplier_count"
    t.string "availability", limit: 20
    t.jsonb "metadata"
    t.string "name"
    t.string "units"
  end

  create_table "prices_daily_summary", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "code", limit: 100, null: false
    t.date "date", null: false
    t.string "type_name", limit: 50, default: "spot_price"
    t.decimal "avg_value", precision: 20, scale: 6
    t.decimal "min_value", precision: 20, scale: 6
    t.decimal "max_value", precision: 20, scale: 6
    t.decimal "open_value", precision: 20, scale: 6
    t.decimal "close_value", precision: 20, scale: 6
    t.integer "sample_count", default: 0
    t.string "currency", limit: 10
    t.string "source", limit: 100
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["code", "date", "type_name"], name: "idx_daily_summary_unique", unique: true
    t.index ["code", "date"], name: "idx_daily_summary_code_date_desc", order: { date: :desc }
    t.index ["date", "code"], name: "idx_daily_summary_date_code"
  end

  create_table "referrals", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "referrer_id", null: false
    t.uuid "referred_id"
    t.string "referral_code", null: false
    t.string "status", default: "pending", null: false
    t.decimal "commission_rate", precision: 5, scale: 4, default: "0.2"
    t.decimal "commission_earned", precision: 10, scale: 2, default: "0.0"
    t.datetime "first_payment_at"
    t.datetime "last_payment_at"
    t.integer "total_referrals", default: 0
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_referrals_on_created_at"
    t.index ["referral_code"], name: "index_referrals_on_referral_code", unique: true
    t.index ["referred_id"], name: "index_referrals_on_referred_id"
    t.index ["referrer_id"], name: "index_referrals_on_referrer_id"
    t.index ["status"], name: "index_referrals_on_status"
  end

  create_table "scraping_logs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "data_type", null: false
    t.string "status", null: false
    t.integer "records_processed", default: 0
    t.string "source"
    t.text "error_message"
    t.datetime "scraped_at", precision: nil, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_scraping_logs_on_created_at"
    t.index ["data_type", "status"], name: "index_scraping_logs_on_data_type_and_status"
    t.index ["scraped_at"], name: "index_scraping_logs_on_scraped_at"
  end

  create_table "sms_conversations", force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "phone_number", null: false
    t.string "status", default: "active"
    t.string "conversation_type"
    t.jsonb "context", default: {}
    t.datetime "last_message_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["phone_number"], name: "index_sms_conversations_on_phone_number"
    t.index ["user_id", "status"], name: "index_sms_conversations_on_user_id_and_status"
  end

  create_table "sms_messages", force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "message_type", null: false
    t.string "channel", null: false
    t.string "direction", default: "outbound"
    t.string "to_number", null: false
    t.string "from_number", null: false
    t.text "content"
    t.string "status"
    t.string "twilio_message_sid"
    t.string "twilio_status"
    t.string "error_message"
    t.jsonb "metadata", default: {}
    t.decimal "cost_cents"
    t.datetime "sent_at"
    t.datetime "delivered_at"
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["direction"], name: "index_sms_messages_on_direction"
    t.index ["message_type", "created_at"], name: "index_sms_messages_on_message_type_and_created_at"
    t.index ["twilio_message_sid"], name: "index_sms_messages_on_twilio_message_sid"
    t.index ["user_id", "created_at"], name: "index_sms_messages_on_user_id_and_created_at"
  end

  create_table "sms_notification_preferences", force: :cascade do |t|
    t.uuid "user_id", null: false
    t.boolean "price_alerts", default: true
    t.boolean "limit_warnings", default: true
    t.boolean "security_alerts", default: true
    t.boolean "system_alerts", default: false
    t.boolean "marketing_messages", default: false
    t.decimal "price_change_threshold", precision: 5, scale: 2, default: "5.0"
    t.integer "limit_warning_threshold", default: 80
    t.integer "quiet_hours_start"
    t.integer "quiet_hours_end"
    t.string "timezone", default: "America/New_York"
    t.integer "daily_limit", default: 10
    t.integer "messages_sent_today", default: 0
    t.date "last_reset_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["last_reset_date"], name: "index_sms_notification_preferences_on_last_reset_date"
    t.index ["user_id"], name: "index_sms_notification_preferences_on_user_id", unique: true
  end

  create_table "spot_prices", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "commodity_code", null: false
    t.decimal "price", precision: 10, scale: 4, null: false
    t.string "source"
    t.datetime "timestamp", null: false
    t.index ["commodity_code", "timestamp"], name: "index_spot_prices_on_commodity_code_and_timestamp"
    t.index ["timestamp"], name: "index_spot_prices_on_timestamp"
    t.unique_constraint ["commodity_code"], name: "unique_commodity_code"
  end

  create_table "storage_data", force: :cascade do |t|
    t.string "code", null: false
    t.string "location", null: false
    t.string "commodity_type"
    t.bigint "volume"
    t.string "units", default: "barrels"
    t.decimal "capacity_utilization", precision: 5, scale: 2
    t.bigint "operational_capacity"
    t.bigint "total_capacity"
    t.decimal "week_change", precision: 10, scale: 2
    t.decimal "month_change", precision: 10, scale: 2
    t.string "source"
    t.jsonb "metadata", default: {}
    t.datetime "data_date", null: false
    t.datetime "release_date"
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.datetime "updated_at", default: -> { "now()" }, null: false
    t.index ["code", "data_date"], name: "index_storage_data_on_code_and_data_date", unique: true
  end

  create_table "stripe_sync_audit_log", id: :serial, force: :cascade do |t|
    t.uuid "user_id"
    t.string "email", limit: 255
    t.string "stripe_customer_id", limit: 255
    t.string "old_plan", limit: 255
    t.string "new_plan", limit: 255
    t.integer "old_limit"
    t.integer "new_limit"
    t.string "action_taken", limit: 255
    t.datetime "sync_date", precision: nil, default: -> { "now()" }
    t.text "notes"
  end

  create_table "stripe_webhook_events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "stripe_event_id", null: false
    t.string "event_type", null: false
    t.jsonb "payload", null: false
    t.string "status", default: "pending"
    t.integer "attempts", default: 0
    t.text "error_message"
    t.datetime "processed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_type"], name: "index_stripe_webhook_events_on_event_type"
    t.index ["status", "attempts"], name: "index_stripe_webhook_events_on_status_and_attempts"
    t.index ["stripe_event_id"], name: "index_stripe_webhook_events_on_stripe_event_id", unique: true
  end

  create_table "uk_gas_fix_log_20250829", id: false, force: :cascade do |t|
    t.datetime "fix_timestamp", precision: nil, default: -> { "now()" }
    t.integer "records_fixed"
    t.decimal "min_before"
    t.decimal "max_before"
    t.decimal "min_after"
    t.decimal "max_after"
  end

  create_table "uk_natgas_backup_20250822", id: false, force: :cascade do |t|
    t.uuid "id"
    t.integer "value_units"
    t.text "code"
    t.text "currency"
    t.text "source"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "type_name"
  end

  create_table "upgrade_offers", force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "trigger_type", null: false
    t.string "coupon_code"
    t.string "recommended_tier"
    t.integer "usage_at_trigger"
    t.integer "limit_at_trigger"
    t.datetime "sent_at", precision: nil
    t.datetime "opened_at", precision: nil
    t.datetime "clicked_at", precision: nil
    t.datetime "converted_at", precision: nil
    t.string "postmark_message_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["converted_at"], name: "idx_upgrade_offers_converted_at"
    t.index ["sent_at"], name: "idx_upgrade_offers_sent_at"
    t.index ["user_id", "trigger_type", "created_at"], name: "idx_upgrade_offers_user_trigger"
  end

  create_table "user_api_request_counts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.date "period_date", null: false
    t.string "period_type", limit: 20, null: false
    t.integer "request_count", default: 0, null: false
    t.datetime "last_incremented_at", precision: nil
    t.datetime "created_at", precision: nil, default: -> { "now()" }, null: false
    t.datetime "updated_at", precision: nil, default: -> { "now()" }, null: false
    t.index ["period_date"], name: "idx_user_api_counts_date"
    t.index ["user_id", "period_date", "period_type"], name: "idx_user_api_counts_unique", unique: true
    t.index ["user_id"], name: "idx_user_api_counts_user"
  end

  create_table "user_insights", force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "insight_type", null: false
    t.jsonb "data", default: {}, null: false
    t.datetime "created_at", null: false
    t.index ["created_at"], name: "index_user_insights_on_created_at"
    t.index ["data"], name: "index_user_insights_on_data", using: :gin
    t.index ["insight_type"], name: "index_user_insights_on_insight_type"
    t.index ["user_id", "insight_type"], name: "index_user_insights_on_user_id_and_insight_type"
    t.index ["user_id"], name: "index_user_insights_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.text "name"
    t.text "email"
    t.boolean "terms_accepted", default: false
    t.text "password_digest", default: "", null: false
    t.datetime "email_confirmed_at", precision: nil
    t.text "email_confirmation_token"
    t.text "password_reset_token"
    t.text "reset_password_sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "plan", default: "free"
    t.datetime "email_confirmation_sent_at", precision: nil
    t.boolean "admin", default: false
    t.integer "request_limit", default: 100
    t.text "stripe_customer_id"
    t.boolean "email_undeliverable", default: false
    t.datetime "email_undeliverable_at"
    t.boolean "reservoir_mastery", default: false
    t.boolean "api_access_suspended", default: false, null: false
    t.datetime "api_access_suspended_at"
    t.text "api_access_suspended_reason"
    t.integer "email_engagement_score", default: 0
    t.datetime "last_email_engagement_at", precision: nil
    t.boolean "email_marketing_consent", default: true
    t.datetime "email_unsubscribed_at", precision: nil
    t.string "email_undeliverable_reason", limit: 255
    t.string "phone"
    t.string "country_code"
    t.string "phone_number"
    t.string "phone_country_code"
    t.boolean "phone_verified", default: false
    t.datetime "phone_verified_at"
    t.boolean "sms_enabled", default: false
    t.boolean "whatsapp_enabled", default: false
    t.uuid "organization_id"
    t.boolean "sms_consent_given", default: false
    t.datetime "sms_consent_given_at"
    t.string "sms_consent_ip"
    t.text "sms_consent_user_agent"
    t.string "sms_terms_version"
    t.boolean "sms_marketing_consent", default: false
    t.datetime "sms_consent_revoked_at"
    t.string "sms_opt_in_source"
    t.string "sms_phone_number"
    t.string "sms_verification_code"
    t.datetime "sms_verification_sent_at"
    t.integer "sms_verification_attempts", default: 0
    t.boolean "sms_price_alerts", default: true
    t.boolean "sms_account_alerts", default: true
    t.decimal "account_credit", precision: 10, scale: 2, default: "0.0"
    t.decimal "total_credits_earned", precision: 10, scale: 2, default: "0.0"
    t.integer "pricing_test_group"
    t.datetime "pricing_test_assigned_at"
    t.integer "account_credit_cents", default: 0, null: false
    t.integer "webhook_limit", default: 0, null: false
    t.integer "webhook_events_limit", default: 1000, null: false
    t.datetime "onboarding_day1_email_sent_at", precision: nil
    t.datetime "onboarding_day3_email_sent_at", precision: nil
    t.datetime "onboarding_day7_email_sent_at", precision: nil
    t.datetime "email_marketing_consent_given_at", precision: nil
    t.inet "email_marketing_consent_ip"
    t.string "email_marketing_legal_basis"
    t.text "email_unsubscribe_reason"
    t.inet "email_unsubscribe_ip"
    t.boolean "marketing_emails_enabled", default: true
    t.integer "max_marketing_emails_per_week", default: 2
    t.integer "marketing_emails_sent_this_week", default: 0
    t.datetime "marketing_email_week_starts_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "last_marketing_email_sent_at", precision: nil
    t.date "current_week_start"
    t.datetime "grace_period_until", precision: nil
    t.string "grace_period_reason"
    t.string "grace_period_granted_by"
    t.integer "grace_period_requests_limit"
    t.integer "grace_period_requests_used", default: 0
    t.string "email_test_group"
    t.boolean "sms_notifications_enabled", default: false
    t.datetime "sms_opt_in_at"
    t.datetime "sms_opt_out_at"
    t.datetime "welcome_email_sent_at", precision: nil
    t.string "user_segment", limit: 50
    t.datetime "segment_updated_at", precision: nil
    t.datetime "engagement_email_sent_at", precision: nil
    t.string "ppp_country_code", limit: 2
    t.decimal "ppp_multiplier", precision: 4, scale: 2
    t.datetime "ppp_verified_at", precision: nil
    t.datetime "ppp_expires_at", precision: nil
    t.jsonb "grandfathered_features", default: {}
    t.string "utm_source"
    t.string "utm_medium"
    t.string "utm_campaign"
    t.string "utm_content"
    t.string "utm_term"
    t.text "referrer_url"
    t.text "landing_page"
    t.integer "api_requests_count", default: 0, null: false
    t.jsonb "email_preferences", default: {}, null: false
    t.datetime "last_monetization_email_at", precision: nil
    t.datetime "trial_ends_at", precision: nil
    t.datetime "trial_started_at", precision: nil
    t.integer "trial_request_limit", default: 10000
    t.integer "trial_requests_used", default: 0
    t.string "google_uid"
    t.string "provider"
    t.string "avatar_url"
    t.index "lower(email)", name: "idx_users_email_lower"
    t.index ["account_credit"], name: "index_users_on_account_credit"
    t.index ["api_access_suspended"], name: "index_users_on_api_access_suspended"
    t.index ["api_requests_count"], name: "index_users_on_api_requests_count"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["email_engagement_score"], name: "idx_users_email_engagement_score"
    t.index ["email_marketing_consent"], name: "idx_users_email_marketing_consent"
    t.index ["email_test_group"], name: "index_users_on_email_test_group"
    t.index ["email_undeliverable"], name: "index_users_on_email_undeliverable"
    t.index ["google_uid"], name: "index_users_on_google_uid", unique: true, where: "(google_uid IS NOT NULL)"
    t.index ["grace_period_until"], name: "index_users_on_grace_period_until"
    t.index ["last_monetization_email_at"], name: "index_users_on_last_monetization_email_at"
    t.index ["name"], name: "index_users_on_name"
    t.index ["organization_id"], name: "index_users_on_organization_id"
    t.index ["phone"], name: "index_users_on_phone"
    t.index ["phone_country_code", "phone_number"], name: "index_users_on_phone_country_code_and_phone_number"
    t.index ["phone_number"], name: "index_users_on_phone_number"
    t.index ["phone_verified"], name: "index_users_on_phone_verified"
    t.index ["ppp_country_code"], name: "index_users_on_ppp_country_code"
    t.index ["ppp_expires_at"], name: "index_users_on_ppp_expires_at"
    t.index ["ppp_verified_at"], name: "index_users_on_ppp_verified_at"
    t.index ["pricing_test_assigned_at"], name: "index_users_on_pricing_test_assigned_at"
    t.index ["pricing_test_group"], name: "index_users_on_pricing_test_group"
    t.index ["reservoir_mastery"], name: "index_users_on_reservoir_mastery"
    t.index ["sms_consent_given", "plan"], name: "index_users_on_sms_consent_given_and_plan"
    t.index ["sms_consent_given"], name: "index_users_on_sms_consent_given"
    t.index ["sms_enabled", "phone_verified"], name: "index_users_on_sms_enabled_and_phone_verified"
    t.index ["sms_notifications_enabled"], name: "index_users_on_sms_notifications_enabled"
    t.index ["sms_phone_number"], name: "index_users_on_sms_phone_number"
    t.index ["trial_ends_at"], name: "index_users_on_trial_ends_at", where: "(trial_ends_at IS NOT NULL)"
    t.index ["utm_campaign"], name: "index_users_on_utm_campaign"
    t.index ["utm_medium"], name: "index_users_on_utm_medium"
    t.index ["utm_source"], name: "index_users_on_utm_source"
    t.index ["webhook_limit"], name: "index_users_on_webhook_limit"
  end

  create_table "webhook_endpoints", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "url", limit: 2048, null: false
    t.string "secret", limit: 128, null: false
    t.string "status", limit: 20, default: "active", null: false
    t.jsonb "events", default: [], null: false
    t.jsonb "commodity_filters", default: [], null: false
    t.integer "failure_count", default: 0, null: false
    t.datetime "last_failure_at"
    t.datetime "last_triggered_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["events"], name: "index_webhook_endpoints_on_events", using: :gin
    t.index ["failure_count"], name: "index_webhook_endpoints_on_failure_count"
    t.index ["last_triggered_at"], name: "index_webhook_endpoints_on_last_triggered_at"
    t.index ["status"], name: "index_webhook_endpoints_on_status"
    t.index ["user_id", "status", "last_triggered_at"], name: "index_webhook_endpoints_active_recent", where: "((status)::text = 'active'::text)"
    t.index ["user_id", "status"], name: "index_webhook_endpoints_on_user_id_and_status"
    t.index ["user_id"], name: "index_webhook_endpoints_on_user_id"
    t.check_constraint "failure_count >= 0", name: "webhook_endpoints_failure_count_positive"
    t.check_constraint "jsonb_typeof(commodity_filters) = 'array'::text", name: "webhook_endpoints_commodity_filters_is_array"
    t.check_constraint "jsonb_typeof(events) = 'array'::text", name: "webhook_endpoints_events_is_array"
    t.check_constraint "status::text = ANY (ARRAY['active'::character varying, 'inactive'::character varying, 'paused'::character varying]::text[])", name: "webhook_endpoints_status_check"
    t.check_constraint "url::text ~ '^https://[^\\s]+$'::text", name: "webhook_endpoints_url_https_check"
  end

  create_table "webhook_events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "webhook_endpoint_id", null: false
    t.string "event_type", limit: 100, null: false
    t.jsonb "payload", null: false
    t.string "status", limit: 20, default: "pending", null: false
    t.integer "attempts", default: 0, null: false
    t.integer "response_code"
    t.text "response_body"
    t.datetime "delivered_at"
    t.datetime "next_retry_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["attempts"], name: "index_webhook_events_on_attempts"
    t.index ["created_at"], name: "index_webhook_events_cleanup", where: "((status)::text = ANY ((ARRAY['delivered'::character varying, 'failed'::character varying])::text[]))"
    t.index ["event_type", "created_at"], name: "index_webhook_events_on_event_type_and_created_at", order: { created_at: :desc }
    t.index ["event_type"], name: "index_webhook_events_on_event_type"
    t.index ["next_retry_at"], name: "index_webhook_events_retry_queue", where: "(((status)::text = 'failed'::text) AND (attempts < 5))"
    t.index ["status", "next_retry_at", "attempts"], name: "index_webhook_events_retry_ready", where: "(((status)::text = 'failed'::text) AND (attempts < 5))"
    t.index ["status", "next_retry_at"], name: "index_webhook_events_on_status_and_next_retry_at"
    t.index ["status"], name: "index_webhook_events_on_status"
    t.index ["webhook_endpoint_id", "created_at"], name: "index_webhook_events_on_webhook_endpoint_id_and_created_at", order: { created_at: :desc }
    t.index ["webhook_endpoint_id"], name: "index_webhook_events_on_webhook_endpoint_id"
    t.check_constraint "attempts >= 0 AND attempts <= 5", name: "webhook_events_attempts_range"
    t.check_constraint "jsonb_typeof(payload) = 'object'::text", name: "webhook_events_payload_is_object"
    t.check_constraint "response_code IS NULL OR response_code >= 100 AND response_code <= 599", name: "webhook_events_response_code_valid"
    t.check_constraint "status::text = ANY (ARRAY['pending'::character varying, 'delivered'::character varying, 'failed'::character varying]::text[])", name: "webhook_events_status_check"
  end

  add_foreign_key "addon_subscriptions", "users", name: "addon_subscriptions_user_id_fkey"
  add_foreign_key "alert_triggers", "price_alerts"
  add_foreign_key "alert_triggers", "users"
  add_foreign_key "api_requests", "organizations"
  add_foreign_key "api_usage_violations", "users"
  add_foreign_key "billing_subscriptions", "organizations", name: "fk_rails_billing_subscriptions_organization"
  add_foreign_key "credit_purchases", "credit_packs", name: "credit_purchases_credit_pack_id_fkey"
  add_foreign_key "credit_purchases", "users", name: "credit_purchases_user_id_fkey"
  add_foreign_key "dark_data_drilling_productivities", "dark_data_reports", name: "dark_data_drilling_productivities_dark_data_report_id_fkey"
  add_foreign_key "dark_data_oil_inventories", "dark_data_reports", name: "dark_data_oil_inventories_dark_data_report_id_fkey"
  add_foreign_key "dark_data_opec_productions", "dark_data_reports", name: "dark_data_opec_productions_dark_data_report_id_fkey"
  add_foreign_key "dark_data_rig_counts", "dark_data_reports", name: "dark_data_rig_counts_dark_data_report_id_fkey"
  add_foreign_key "email_campaign_logs", "feedback_experiments", name: "email_campaign_logs_feedback_experiment_id_fkey"
  add_foreign_key "email_campaign_logs", "users"
  add_foreign_key "email_delivery_logs", "users", name: "email_delivery_logs_user_id_fkey"
  add_foreign_key "entity_identifiers", "entities"
  add_foreign_key "feedback_responses", "email_campaign_logs", name: "feedback_responses_email_campaign_log_id_fkey"
  add_foreign_key "feedback_responses", "feedback_experiments", name: "feedback_responses_feedback_experiment_id_fkey"
  add_foreign_key "feedback_responses", "users", column: "followed_up_by", name: "feedback_responses_followed_up_by_fkey"
  add_foreign_key "feedback_responses", "users", name: "feedback_responses_user_id_fkey"
  add_foreign_key "in_app_notifications", "users"
  add_foreign_key "notification_preferences", "users"
  add_foreign_key "organization_invitations", "organizations"
  add_foreign_key "organization_invitations", "users", column: "invited_by_id"
  add_foreign_key "organization_members", "organizations"
  add_foreign_key "organization_members", "users"
  add_foreign_key "organizations", "users", column: "owner_user_id"
  add_foreign_key "phone_verifications", "users"
  add_foreign_key "ppp_fraud_checks", "users", name: "ppp_fraud_checks_user_id_fkey"
  add_foreign_key "ppp_verification_signals", "users", name: "ppp_verification_signals_user_id_fkey"
  add_foreign_key "price_alerts", "users"
  add_foreign_key "referrals", "users", column: "referred_id"
  add_foreign_key "referrals", "users", column: "referrer_id"
  add_foreign_key "sms_conversations", "users"
  add_foreign_key "sms_messages", "users"
  add_foreign_key "sms_notification_preferences", "users"
  add_foreign_key "upgrade_offers", "users", name: "upgrade_offers_user_id_fkey"
  add_foreign_key "user_insights", "users"
  add_foreign_key "users", "organizations"
  add_foreign_key "webhook_endpoints", "users"
  add_foreign_key "webhook_events", "webhook_endpoints"
end
