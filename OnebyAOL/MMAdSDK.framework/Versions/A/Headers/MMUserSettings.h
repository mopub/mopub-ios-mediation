//
//  MMUserSettings.h
//  MMAdSDK
//
//  Copyright (c) 2015 Millennial Media, Inc. All rights reserved.
//

#ifndef MMUserSettings_Header_h
#define MMUserSettings_Header_h

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSInteger, MMEthnicity) {
    MMEthnicityHispanic = 1,
    MMEthnicityBlack,
    MMEthnicityAsian,
    MMEthnicityIndian,
    MMEthnicityMiddleEastern,
    MMEthnicityNativeAmerican,
    MMEthnicityPacificIslander,
    MMEthnicityWhite,
    MMEthnicityOther
};

typedef NS_ENUM (NSInteger, MMGender) {
    MMGenderMale = 1,
    MMGenderFemale,
    MMGenderOther
};

typedef NS_ENUM (NSInteger, MMMaritalStatus) {
    MMMaritalSingle = 1,
    MMMaritalMarried,
    MMMaritalDivorced,
    MMMaritalOther
};

typedef NS_ENUM (NSInteger, MMEducation) {
    MMEducationHighSchool = 1,
    MMEducationSomeCollege,
    MMEducationAssociates,
    MMEducationBachelors,
    MMEducationMasters,
    MMEducationDoctorate,
    MMEducationProfessional
};

typedef NS_ENUM (NSInteger, MMPolitics) {
    MMPoliticsRepublican = 1,
    MMPoliticsDemocrat,
    MMPoliticsConservative,
    MMPoliticsModerate,
    MMPoliticsLiberal,
    MMPoliticsIndependent,
    MMPoliticsOther
};

/**
 * The object used to configure persistent app-wide settings for the current user of the application.
 * If your application collects user profile information, this object should be updated whenever that 
 * information changes.
 *
 * Please note that the information set in this object WILL NOT be sent on ad requests for users under the jurisdiction of GDPR or similar future privacy regulations that have not consented to the use of their personal data for advertising purposes.
 */
@interface MMUserSettings : NSObject

/** The user's age. */
@property (nonatomic, strong, nullable) NSNumber *age;

/** The user's date of birth. */
@property (nonatomic, strong, nullable) NSDate *dob;

/** The number of children the user has. */
@property (nonatomic, strong, nullable) NSNumber *children;

/** The user's annual income. */
@property (nonatomic, strong, nullable) NSNumber *income;

/** The user's education level. */
@property (nonatomic, assign) MMEducation education;

/** The user's ethnicity. */
@property (nonatomic, assign) MMEthnicity ethnicity;

/** The user's gender. */
@property (nonatomic, assign) MMGender gender;

/** The user's marital status. */
@property (nonatomic, assign) MMMaritalStatus maritalStatus;

/** The user's political affiliation. */
@property (nonatomic, assign) MMPolitics politics;

/** The user's state or province of residence. Use the standard two character abbreviation for US State, e.g. `GA`. */
@property (nonatomic, copy, nullable) NSString *state;

/** The user's DMA. Standard 3 character DMA code. e.g. `501` */
@property (nonatomic, copy, nullable) NSString *dma;

/** The user's postal code, e.g. `90210` or `M9A3G9` */
@property (nonatomic, copy, nullable) NSString* postalCode;

/** The user's country of residence. */
@property (nonatomic, copy, nullable) NSString *country;

/** Keywords relevant to the current user of the application, e.g. `["sports", "huey lewis"]` */
@property (nonatomic, copy, nullable) NSArray *keywords;

@end

#endif
