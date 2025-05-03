# Changelog

All notable changes to Coffee Mapper Web will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.1] - 2024-03-19

### Added
- Enhanced Excel export functionality for all table components
- Comprehensive data mapping for beneficiary exports
- Additional fields in beneficiary exports including banking and personal details

### Changed
- Updated web API implementation from `dart:html` to modern `package:web`
- Improved Excel file generation with proper sheet management
- Enhanced data type handling in Excel exports

### Fixed
- TypeError issues with double values in Excel exports
- Extra "Sheet1" appearing in exported Excel files
- Web API deprecation warnings
- Beneficiary data export field alignment
- Excel cell value type conversion issues

## [1.1.0] - 2024-02-14

### Added
- Real-time dashboard with live metrics
- Interactive data visualization
- Multi-level filtering system
- Google Maps integration
- Media management system
- Role-based access control
- Comprehensive plantation overview
- Progress tracking and monitoring

### Changed
- Enhanced UI/UX design
- Improved performance optimizations
- Updated Firebase security rules

### Fixed
- Authentication flow issues
- Data synchronization bugs
- Map rendering performance

## [1.0.0] - 2024-01-01

### Added
- Initial release
- Basic dashboard functionality
- Firebase integration
- User authentication
- Coffee plantation tracking
- Shade tree management
- Area and perimeter calculations
- Basic reporting features

## Excel Export Functionality Improvements

### Bug Fixes
1. Fixed TypeError for double values in Excel export
   - Modified `exportToExcel` to properly convert all values to `TextCellValue`
   - Added handling for null values with empty string fallback

2. Removed Extra "Sheet1" in Excel Files
   - Added logic to remove default "Sheet1" when creating custom sheets
   - Implemented check to preserve sheet if it's the target sheet

3. Fixed Web API Deprecation
   - Updated from deprecated `dart:html` to `package:web` and `dart:js_interop`
   - Implemented proper type conversions for Blob and anchor element creation

### Data Mapping Enhancements
1. Updated Beneficiary Data Export Fields
   - Aligned `tableData` mapping with `beneficiaryAdminColumns`
   - Added missing fields:
     - Class Type
     - Mobile Number
     - Khata Number
     - Plot Number
     - Mauja
   - Ensured correct order of all 19 columns

### Code Structure Improvements
1. Excel Export Utility (`ExcelExportUtils`)
   - Enhanced error handling
   - Added proper type conversions
   - Improved file download mechanism

2. Header Components
   - Maintained filter functionality while improving data export
   - Ensured consistent data mapping across components 