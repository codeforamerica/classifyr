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

ActiveRecord::Schema[7.0].define(version: 2022_04_05_224432) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.integer "row_count", default: 0
    t.string "headers"
    t.date "start_date"
    t.date "end_date"
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "classifications", force: :cascade do |t|
    t.bigint "common_incident_type_id"
    t.integer "user_id"
    t.string "common_type"
    t.string "value"
    t.boolean "unknown", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["common_incident_type_id"], name: "index_classifications_on_common_incident_type_id"
  end

  create_table "common_incident_types", force: :cascade do |t|
    t.string "standard", default: "APCO"
    t.string "version", default: "2.103.2-2019"
    t.string "code"
    t.string "description"
    t.string "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "humanized_code"
    t.string "humanized_description"
  end

  create_table "data_sets", force: :cascade do |t|
    t.string "title"
    t.string "data_link"
    t.string "documentation_link"
    t.string "api_links"
    t.string "source"
    t.string "exclusions"
    t.string "format"
    t.text "license"
    t.text "description"
    t.string "city"
    t.string "state"
    t.string "headers"
    t.boolean "has_911"
    t.boolean "has_fire"
    t.boolean "has_ems"
    t.boolean "analyzed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "fields", force: :cascade do |t|
    t.bigint "data_set_id"
    t.string "heading"
    t.integer "position"
    t.string "common_type"
    t.string "common_format"
    t.integer "unique_value_count"
    t.integer "empty_value_count"
    t.text "sample_data"
    t.string "min_value"
    t.string "max_value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["data_set_id"], name: "index_fields_on_data_set_id"
  end

  create_table "unique_values", force: :cascade do |t|
    t.bigint "field_id"
    t.string "value"
    t.integer "frequency"
    t.index ["field_id"], name: "index_unique_values_on_field_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
end
