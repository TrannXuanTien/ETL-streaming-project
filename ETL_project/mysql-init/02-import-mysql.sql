USE DE1;
LOAD DATA INFILE '/var/lib/mysql-files/campaign.csv'
INTO TABLE campaign
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    @id, @created_by, @created_date, @last_modified_by, @last_modified_date,
    @is_active, @campaign_name, @budget_total, @unit_budget, @start_date,
    @end_date, @close_date, @campaign_status, @background_status, @pacing_unit,
    @company_id, @number_of_pacing, @recommend_budget, @import_xml_url, @bid_set,
    @ats_type, @ats_data
)
SET 
    id = NULLIF(@id, ''),
    created_by = NULLIF(@created_by, ''),
    created_date = NULLIF(@created_date, ''),
    last_modified_by = NULLIF(@last_modified_by, ''),
    last_modified_date = NULLIF(@last_modified_date, ''),
    is_active = NULLIF(@is_active, ''),
    campaign_name = NULLIF(@campaign_name, ''),
    budget_total = NULLIF(@budget_total, ''),
    unit_budget = NULLIF(@unit_budget, ''),
    start_date = NULLIF(@start_date, ''),
    end_date = NULLIF(@end_date, ''),
    close_date = NULLIF(@close_date, ''),
    campaign_status = NULLIF(@campaign_status, ''),
    background_status = NULLIF(@background_status, ''),
    pacing_unit = NULLIF(@pacing_unit, ''),
    company_id = NULLIF(@company_id, ''),
    number_of_pacing = NULLIF(@number_of_pacing, ''),
    recommend_budget = NULLIF(@recommend_budget, ''),
    import_xml_url = NULLIF(@import_xml_url, ''),
    bid_set = NULLIF(@bid_set, ''),
    ats_type = NULLIF(@ats_type, ''),
    ats_data = NULLIF(@ats_data, '');

LOAD DATA INFILE '/var/lib/mysql-files/job.csv'
INTO TABLE job
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    @id, @created_by, @created_date, @last_modified_by, @last_modified_date,
    @is_active, @title, @description, @work_schedule, @radius_unit,
    @location_state, @location_list, @role_location, @resume_option, @budget,
    @status, @error, @template_question_id, @template_question_name, @question_form_description,
    @redirect_url, @start_date, @end_date, @close_date, @group_id,
    @minor_id, @campaign_id, @company_id, @history_status, @ref_id
)
SET 
    id = NULLIF(@id, ''),
    created_by = NULLIF(@created_by, ''),
    created_date = NULLIF(@created_date, ''),
    last_modified_by = NULLIF(@last_modified_by, ''),
    last_modified_date = NULLIF(@last_modified_date, ''),
    is_active = NULLIF(@is_active, ''),
    title = NULLIF(@title, ''),
    description = NULLIF(@description, ''),
    work_schedule = NULLIF(@work_schedule, ''),
    radius_unit = NULLIF(@radius_unit, ''),
    location_state = NULLIF(@location_state, ''),
    location_list = NULLIF(@location_list, ''),
    role_location = NULLIF(@role_location, ''),
    resume_option = NULLIF(@resume_option, ''),
    budget = NULLIF(@budget, ''),
    status = NULLIF(@status, ''),
    error = NULLIF(@error, ''),
    template_question_id = NULLIF(@template_question_id, ''),
    template_question_name = NULLIF(@template_question_name, ''),
    question_form_description = NULLIF(@question_form_description, ''),
    redirect_url = NULLIF(@redirect_url, ''),
    start_date = NULLIF(@start_date, ''),
    end_date = NULLIF(@end_date, ''),
    close_date = NULLIF(@close_date, ''),
    group_id = NULLIF(@group_id, ''),
    minor_id = NULLIF(@minor_id, ''),
    campaign_id = NULLIF(@campaign_id, ''),
    company_id = NULLIF(@company_id, ''),
    history_status = NULLIF(@history_status, ''),
    ref_id = NULLIF(@ref_id, '');

LOAD DATA INFILE '/var/lib/mysql-files/company.csv'
INTO TABLE company
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    @id, @created_by, @created_date, @last_modified_by, @last_modified_date,
    @is_active, @name, @is_agree_conditon, @is_agree_sign_deal, @sign_deal_user,
    @billing_id, @manage_type, @customer_type, @status, @publisher_id,
    @flat_rate, @percentage_of_click, @logo
)
SET 
    id = NULLIF(@id, ''),
    created_by = NULLIF(@created_by, ''),
    created_date = NULLIF(@created_date, ''),
    last_modified_by = NULLIF(@last_modified_by, ''),
    last_modified_date = NULLIF(@last_modified_date, ''),
    is_active = NULLIF(@is_active, ''),
    name = NULLIF(@name, ''),
    is_agree_conditon = NULLIF(@is_agree_conditon, ''),
    is_agree_sign_deal = NULLIF(@is_agree_sign_deal, ''),
    sign_deal_user = NULLIF(@sign_deal_user, ''),
    billing_id = NULLIF(@billing_id, ''),
    manage_type = NULLIF(@manage_type, ''),
    customer_type = NULLIF(@customer_type, ''),
    status = NULLIF(@status, ''),
    publisher_id = NULLIF(@publisher_id, ''),
    flat_rate = NULLIF(@flat_rate, ''),
    percentage_of_click = NULLIF(@percentage_of_click, ''),
    logo = NULLIF(@logo, '');

LOAD DATA INFILE '/var/lib/mysql-files/events.csv'
INTO TABLE events
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    @job_id, @dates, @hours, @disqualified_application,
    @qualified_application, @conversion, @company_id, @group_id, @campaign_id,
    @publisher_id, @bid_set, @clicks, @impressions, @spend_hour, @sources
)
SET 
    job_id = NULLIF(@job_id, ''),
    dates = NULLIF(@dates, ''),
    hours = NULLIF(@hours, ''),
    disqualified_application = NULLIF(@disqualified_application, ''),
    qualified_application = NULLIF(@qualified_application, ''),
    conversion = NULLIF(@conversion, ''),
    company_id = NULLIF(@company_id, ''),
    group_id = NULLIF(@group_id, ''),
    campaign_id = NULLIF(@campaign_id, ''),
    publisher_id = NULLIF(@publisher_id, ''),
    bid_set = NULLIF(@bid_set, ''),
    clicks = NULLIF(@clicks, ''),
    impressions = NULLIF(@impressions, ''),
    spend_hour = NULLIF(@spend_hour, ''),
    sources = NULLIF(@sources, ''),
	updated_at = NULLIF(@updated_at, '');
	
LOAD DATA INFILE '/var/lib/mysql-files/master_publisher.csv'
INTO TABLE master_publisher
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    @id, @created_by, @created_date, @last_modified_by, @last_modified_date,
    @is_active, @publisher_name, @email, @access_token, @publisher_type,
    @publisher_status, @publisher_frequency, @curency, @time_zone, @cpc_increment,
    @bid_reading, @min_bid, @max_bid, @countries, @data_sharing
)
SET 
    id = NULLIF(@id, ''),
    created_by = NULLIF(@created_by, ''),
    created_date = NULLIF(@created_date, ''),
    last_modified_by = NULLIF(@last_modified_by, ''),
    last_modified_date = NULLIF(@last_modified_date, ''),
    is_active = NULLIF(@is_active, ''),
    publisher_name = NULLIF(@publisher_name, ''),
    email = NULLIF(@email, ''),
    access_token = NULLIF(@access_token, ''),
    publisher_type = NULLIF(@publisher_type, ''),
    publisher_status = NULLIF(@publisher_status, ''),
    publisher_frequency = NULLIF(@publisher_frequency, ''),
    curency = NULLIF(@curency, ''),
    time_zone = NULLIF(@time_zone, ''),
    cpc_increment = NULLIF(@cpc_increment, ''),
    bid_reading = NULLIF(@bid_reading, ''),
    min_bid = NULLIF(@min_bid, ''),
    max_bid = NULLIF(@max_bid, ''),
    countries = NULLIF(@countries, ''),
    data_sharing = NULLIF(@data_sharing, '');