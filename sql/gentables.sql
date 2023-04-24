-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2023-04-24 15:28:49.376

-- tables
-- Table: Couriers
CREATE TABLE Couriers (
    id int  NOT NULL,
    first_name varchar(50)  NOT NULL,
    last_name varchar(50)  NOT NULL,
    phone_number varchar(20)  NOT NULL,
    CONSTRAINT Couriers_pk PRIMARY KEY (id)
);

-- Table: PackageDimensions
CREATE TABLE PackageDimensions (
    id int  NOT NULL,
    name varchar(20)  NOT NULL,
    dimension_x decimal(10,5)  NOT NULL,
    dimension_y decimal(10,5)  NOT NULL,
    dimension_z decimal(10,5)  NOT NULL,
    CONSTRAINT PackageDimensions_pk PRIMARY KEY (id)
);

-- Table: Packages
CREATE TABLE Packages (
    id int  NOT NULL,
    weight decimal(10,5)  NOT NULL,
    dimensions_id int  NOT NULL,
    sender_info_id int  NOT NULL,
    recipient_info_id int  NOT NULL,
    destination_packagepoint_id int  NOT NULL,
    pickedup_time timestamp  NULL,
    CONSTRAINT Packages_pk PRIMARY KEY (id)
);

-- Table: ParcelPointPackages
CREATE TABLE ParcelPointPackages (
    id int  NOT NULL,
    package_id int  NOT NULL,
    parcelpoint_id int  NOT NULL,
    time timestamp  NOT NULL,
    CONSTRAINT ParcelPointPackages_pk PRIMARY KEY (id)
);

-- Table: ParcelPoints
CREATE TABLE ParcelPoints (
    id int  NOT NULL,
    name varchar(100)  NOT NULL,
    city varchar(100)  NOT NULL,
    street varchar(100)  NOT NULL,
    house_number varchar(10)  NOT NULL,
    apartment_humber varchar(10)  NULL,
    CONSTRAINT ParcelPoints_pk PRIMARY KEY (id)
);

-- Table: PersonInfo
CREATE TABLE PersonInfo (
    id int  NOT NULL,
    name varchar(150)  NOT NULL,
    phone_number varchar(20)  NOT NULL,
    email varchar(320)  NULL,
    CONSTRAINT PersonInfo_pk PRIMARY KEY (id)
);

-- Table: RoutePackages
CREATE TABLE RoutePackages (
    route_id int  NOT NULL,
    package_id int  NOT NULL,
    CONSTRAINT RoutePackages_pk PRIMARY KEY (route_id,package_id)
);

-- Table: Routes
CREATE TABLE Routes (
    id int  NOT NULL,
    time timestamp  NOT NULL,
    destination_parcelpoint_id int  NOT NULL,
    source_parcelpoint_id int  NOT NULL,
    vehicle_id int  NOT NULL,
    courier_id int  NOT NULL,
    completed boolean  NOT NULL DEFAULT FALSE,
    CONSTRAINT Routes_pk PRIMARY KEY (id)
);

-- Table: Users
CREATE TABLE Users (
    id int  NOT NULL,
    courier_id int  NULL,
    parcelpoint_id int  NULL,
    email varchar(320)  NOT NULL,
    password_hash varchar(255)  NOT NULL,
    CONSTRAINT Users_pk PRIMARY KEY (id),
	UNIQUE(email)
);

-- Table: Vehicles
CREATE TABLE Vehicles (
    id int  NOT NULL,
    registration_plate varchar(10)  NOT NULL,
    dimension_x decimal(10,5)  NOT NULL,
    dimension_y decimal(10,5)  NOT NULL,
    dimension_z decimal(10,5)  NOT NULL,
    max_weight decimal(10,5)  NOT NULL,
    CONSTRAINT Vehicles_pk PRIMARY KEY (id)
);

-- foreign keys
-- Reference: Packages_CustomerInfo1 (table: Packages)
ALTER TABLE Packages ADD CONSTRAINT Packages_CustomerInfo1
    FOREIGN KEY (recipient_info_id)
    REFERENCES PersonInfo (id)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: Packages_CustomerInfo2 (table: Packages)
ALTER TABLE Packages ADD CONSTRAINT Packages_CustomerInfo2
    FOREIGN KEY (sender_info_id)
    REFERENCES PersonInfo (id)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: Packages_PackageDimensions (table: Packages)
ALTER TABLE Packages ADD CONSTRAINT Packages_PackageDimensions
    FOREIGN KEY (dimensions_id)
    REFERENCES PackageDimensions (id)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: Packages_PackagePoints (table: Packages)
ALTER TABLE Packages ADD CONSTRAINT Packages_PackagePoints
    FOREIGN KEY (destination_packagepoint_id)
    REFERENCES ParcelPoints (id)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: ParcelPointPackages_Packages (table: ParcelPointPackages)
ALTER TABLE ParcelPointPackages ADD CONSTRAINT ParcelPointPackages_Packages
    FOREIGN KEY (package_id)
    REFERENCES Packages (id)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: ParcelPointPackages_ParcelPoints (table: ParcelPointPackages)
ALTER TABLE ParcelPointPackages ADD CONSTRAINT ParcelPointPackages_ParcelPoints
    FOREIGN KEY (parcelpoint_id)
    REFERENCES ParcelPoints (id)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: RoutePackages_Packages (table: RoutePackages)
ALTER TABLE RoutePackages ADD CONSTRAINT RoutePackages_Packages
    FOREIGN KEY (package_id)
    REFERENCES Packages (id)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: RoutePackages_Routes (table: RoutePackages)
ALTER TABLE RoutePackages ADD CONSTRAINT RoutePackages_Routes
    FOREIGN KEY (route_id)
    REFERENCES Routes (id)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: Routes_Courier (table: Routes)
ALTER TABLE Routes ADD CONSTRAINT Routes_Courier
    FOREIGN KEY (courier_id)
    REFERENCES Couriers (id)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: Routes_PackagePoints (table: Routes)
ALTER TABLE Routes ADD CONSTRAINT Routes_PackagePoints
    FOREIGN KEY (destination_parcelpoint_id)
    REFERENCES ParcelPoints (id)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: Routes_ParcelPoints (table: Routes)
ALTER TABLE Routes ADD CONSTRAINT Routes_ParcelPoints
    FOREIGN KEY (source_parcelpoint_id)
    REFERENCES ParcelPoints (id)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: Routes_Vehicles (table: Routes)
ALTER TABLE Routes ADD CONSTRAINT Routes_Vehicles
    FOREIGN KEY (vehicle_id)
    REFERENCES Vehicles (id)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: Users_Couriers (table: Users)
ALTER TABLE Users ADD CONSTRAINT Users_Couriers
    FOREIGN KEY (courier_id)
    REFERENCES Couriers (id)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: Users_ParcelPoints (table: Users)
ALTER TABLE Users ADD CONSTRAINT Users_ParcelPoints
    FOREIGN KEY (parcelpoint_id)
    REFERENCES ParcelPoints (id)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- End of file.

