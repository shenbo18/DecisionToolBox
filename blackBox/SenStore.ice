/* -*- c++ -*- */

/*
 * Copyright (c) 2012 SC Solutions, Inc.
 * See LICENSE.txt.
 * $Id: server-tpl.ice,v 1.27 2013-03-07 22:15:49 glinden Exp $
 *
 * Notice: ZeroC Ice is licensed under GPL, and requires a commercial
 * license when used in closed-source applications.
 */

/**
 * SenStore database
 *
 * ZeroC Ice interface to SenStore cyber-infrastructure server.
 *
 * The [Introspector] interface provides a database schema neutral interface, to
 * retrieve the database definition.  The [SenStoreMngr] interface provides
 * read/write access to the database objects.
 */
module SenStore {
  /**
   * Base class for all server-side exceptions.
   */
  exception ServerError {
    /** Error message. */
    string reason;
  };

  /**
   * Login exception.
   *
   * This exception is thrown when the user provides invalid
   * security information, or attempts non-permitted operations.
   */
  exception SecurityError extends ServerError {};

  /**
   * File access exception.
   *
   * Base class for all server-side file access exceptions.
   */
  exception FileAccessError extends ServerError {};

  /**
   * File write access exception.
   *
   * This exception is thrown when the server cannot write to a file.
   */
  exception FileWriteError extends FileAccessError {};

  /**
   * File read access exception.
   *
   * This exception is thrown when the server cannot read from a file.
   */
  exception FileReadError extends FileAccessError {};

  /**
   * Data access exception.
   *
   * Base class for all server-side data access exceptions.
   */
  exception DataAccessError extends ServerError {};

  /**
   * Object-does-not-exist exception.
   *
   * This exception is thrown when a requested object does not exist.
   */
  exception ObjectDoesNotExistError extends ServerError {};

  /**
   * Data write access exception.
   *
   * This exception is thrown when the server cannot write data.
   */
  exception DataWriteError extends DataAccessError {};

  /**
   * Data read access exception.
   *
   * This exception is thrown when the server cannot read data.
   * Note that most functions just return an empty result when data
   * cannot be found.  This exception is only used when result data
   * is expected, but cannot be provided.
   */
  exception DataReadError extends DataAccessError {};

  /** Data type for holding list of object IDs. */
  sequence <long> IdList;

  /** Raw byte sequence data type. */
  sequence <byte> ByteSeq;

  /** Data type for holding list of dimension sizes or indices. */
  sequence <long> DimensionList;

  /** Data type for holding list of large indices. */
  sequence <long> IndexList;

  /** Data type for holding list of int32s. */
  sequence <int> Int32List;

  /** Data type for holding list of int16s. */
  sequence <short> Int16List;

  /** Data type for holding list of bools. */
  sequence <bool> BoolList;

  /** Data type for holding list of strings. */
  sequence <string> StringList;

  /** Data type for holding list of float64s. */
  sequence <double> Float64List;

  /** Data type for holding list of dates. */
  sequence <double> DateList;

  /** Data type for holding list of timestamps. */
  sequence <double> TimestampList;

  /** Data type for holding list of int64s. */
  sequence <long> Int64List;

  /** Data type for holding list of float32s. */
  sequence <float> Float32List;

  /** Supported database object class types. */
  enum ClassType {
    /* Generic object class. */
    ClassTypeCLASS,
    /** Objects including a multi-dimensional array. */
    ClassTypeARRAY,
    /** Objects including a multi-dimensional time signal. */
    ClassTypeSIGNAL,
  };

  /** List of class types. */
  sequence <ClassType> ClassTypeList;

  /** Time axis info. */
  struct TimeAxisInfo {
    /** Time vector \[s]. */
    TimestampList t;
    /** Index vector. */
    IndexList idx;
  };

  /** Array slice. */
  struct ArraySlice {
    /** Start index (0-based, inclusive). */
    int start;
    /** Step size (<=1 indicates all elements between start (inclusive) and stop (exclusive). */
    int step;
    /** Stop index (0-based, exclusive). */
    int stop;
  };

  /** Data type for holding list of array slices. */
  sequence <ArraySlice> ArraySliceList;

  /** Data type for holding list of field names. */
  sequence <string> FieldNameList;

  /**
   * File information.
   */
  struct FileInfo {
    /** Unique identifier (for internal use only). */
    long id;
    /**
     * File name.
     *
     * Suggested file name.  Note that the server does not store
     * the file using this file name (it may not be unique), but
     * the file name may be helpful for clients wanting to download
     * the file.
     */
    string mFileName;
    /**
     * Time stamp.
     */
    double mTimestamp;
    /**
     * Content type.
     *
     * The content type should be one of the MIME types such as 'image/jpeg'.
     */
    string mContentType;
    /**
     * File contents description.
     *
     * Short description.
     */
    string mDescription;
    /**
     * File size in bytes.
     */
    long mSize;
  };
  
  /** List of file information structures. */
  sequence <FileInfo> FileInfoList;

  /** Data structure with information of a 'signal data updated' event. */
  struct SignalDataUpdatedEvent {
    /** Time-stamp of event. */
    double ts;
    /** Class name of updated signal. */
    string className;
    /** ID of updated signal object. */
    long id;
    /** Time-stamp of start of new or changed data. */
    double tStart;
    /** Time-stamp of end of new or changed data. */
    double tEnd;
  };

  /**
   * Event handler interface.
   *
   * This interface is used by the server to send events using IceStorm.
   * Users can implement this interface and register to the corresponding
   * IceStorm topics to receive these events.
   */
  interface EventHandler {
    /**
     * Report 'signal data arrived' event.
     *
     * @param event
     */
    void reportSignalDataUpdated(SignalDataUpdatedEvent event);
  };


  /** Module for inspecting the database schema. */
  module Info {
    /** Data type for holding list of names. */
    sequence <string> NameList;

    /** Data type for holding map of variable tags. */
    dictionary <string,string> TagMap;

    /** Variable (class data member) meta-data. */
    struct VarInfo {
      /** Variable name. */
      string name;
      /** Variable description. */
      string descr;
      /** Variable data type. */
      string varType;
      /** Variable meta type (var, ref or enumref). */
      string className;
      /** Variable tags. */
      TagMap tags;
    };

    /** List of meta-data of variables. */
    sequence <VarInfo> VarInfoList;

    /** Class meta-data. */
    class ClassInfo {
      /** Class type (class, array or signal). */
      ClassType clsType;
      /** Class name. */
      string name;
      /** Class description. */
      string descr;
      /** Member variables meta-data. */
      VarInfoList vars;
      /** Names of classes that have this class as a parent. */
      NameList childClassNames;
    };

    /** Array meta-data. */
    class ArrayInfo extends ClassInfo {
      /** Data type of array. */
      string dataType;
      /** Array axes meta-data. */
      VarInfoList axes;
      /** Array axes dimensions. */
      DimensionList dims;
    };

    /** Signal meta-data. */
    class SignalInfo extends ArrayInfo {
      /** Dummy member, because extended classes must have at least on additional member. */
      int dummy;
    };

    /**
     * Interface to the database schema.
     *
     * Use this interface to query a database about its defined classes and variables.
     */
    interface Introspector {
      /**
       * Gets the names of the database classes.
       *
       * By specifying the list of class types, a subset of the
       * class types can be retrieved.
       *
       * @param clsTypes list of class types (empty is all)
       */
      idempotent NameList getClassNames(ClassTypeList clsTypes);
      /**
       * Gets the info of the given class.
       *
       * @return class/array/signal info
       */
      idempotent ClassInfo getClassInfo(string name);
    };
  };

  /**
   * Multi-dimensional array data.
   *
   * Note that the vector data must be reshaped to get the
   * multi-dimensional array.  In Python, use:
   * a = numpy.array(myStruct.data);
   * a = a.reshape(myStruct.shape);
   */
  struct Int32Array {
    /** Array dimensions (shape). */
    DimensionList shape;
    /** Array data, stored as a vector. */
    Int32List data;
  };

  /**
   * Multi-dimensional array data.
   *
   * Note that the vector data must be reshaped to get the
   * multi-dimensional array.  In Python, use:
   * a = numpy.array(myStruct.data);
   * a = a.reshape(myStruct.shape);
   */
  struct Int16Array {
    /** Array dimensions (shape). */
    DimensionList shape;
    /** Array data, stored as a vector. */
    Int16List data;
  };

  /**
   * Multi-dimensional array data.
   *
   * Note that the vector data must be reshaped to get the
   * multi-dimensional array.  In Python, use:
   * a = numpy.array(myStruct.data);
   * a = a.reshape(myStruct.shape);
   */
  struct BoolArray {
    /** Array dimensions (shape). */
    DimensionList shape;
    /** Array data, stored as a vector. */
    BoolList data;
  };

  /**
   * Multi-dimensional array data.
   *
   * Note that the vector data must be reshaped to get the
   * multi-dimensional array.  In Python, use:
   * a = numpy.array(myStruct.data);
   * a = a.reshape(myStruct.shape);
   */
  struct StringArray {
    /** Array dimensions (shape). */
    DimensionList shape;
    /** Array data, stored as a vector. */
    StringList data;
  };

  /**
   * Multi-dimensional array data.
   *
   * Note that the vector data must be reshaped to get the
   * multi-dimensional array.  In Python, use:
   * a = numpy.array(myStruct.data);
   * a = a.reshape(myStruct.shape);
   */
  struct Float64Array {
    /** Array dimensions (shape). */
    DimensionList shape;
    /** Array data, stored as a vector. */
    Float64List data;
  };

  /**
   * Multi-dimensional array data.
   *
   * Note that the vector data must be reshaped to get the
   * multi-dimensional array.  In Python, use:
   * a = numpy.array(myStruct.data);
   * a = a.reshape(myStruct.shape);
   */
  struct DateArray {
    /** Array dimensions (shape). */
    DimensionList shape;
    /** Array data, stored as a vector. */
    DateList data;
  };

  /**
   * Multi-dimensional array data.
   *
   * Note that the vector data must be reshaped to get the
   * multi-dimensional array.  In Python, use:
   * a = numpy.array(myStruct.data);
   * a = a.reshape(myStruct.shape);
   */
  struct TimestampArray {
    /** Array dimensions (shape). */
    DimensionList shape;
    /** Array data, stored as a vector. */
    TimestampList data;
  };

  /**
   * Multi-dimensional array data.
   *
   * Note that the vector data must be reshaped to get the
   * multi-dimensional array.  In Python, use:
   * a = numpy.array(myStruct.data);
   * a = a.reshape(myStruct.shape);
   */
  struct Int64Array {
    /** Array dimensions (shape). */
    DimensionList shape;
    /** Array data, stored as a vector. */
    Int64List data;
  };

  /**
   * Multi-dimensional array data.
   *
   * Note that the vector data must be reshaped to get the
   * multi-dimensional array.  In Python, use:
   * a = numpy.array(myStruct.data);
   * a = a.reshape(myStruct.shape);
   */
  struct Float32Array {
    /** Array dimensions (shape). */
    DimensionList shape;
    /** Array data, stored as a vector. */
    Float32List data;
  };
  /**
   * Multi-dimensional signal data.
   *
   * Note that the vector data must be reshaped to get the
   * multi-dimensional array.  In Python, use:
   * a = numpy.array(myStruct.data);
   * a.reshape(myStruct.shape);
   */
  struct Int32Signal {
    /** Array dimensions (shape). */
    DimensionList shape;
    /** Array data, stored as a vector. */
    Int32List data;
    /** Time axis data. */
    TimestampList t;
  };
  /**
   * Multi-dimensional signal data.
   *
   * Note that the vector data must be reshaped to get the
   * multi-dimensional array.  In Python, use:
   * a = numpy.array(myStruct.data);
   * a.reshape(myStruct.shape);
   */
  struct Int16Signal {
    /** Array dimensions (shape). */
    DimensionList shape;
    /** Array data, stored as a vector. */
    Int16List data;
    /** Time axis data. */
    TimestampList t;
  };
  /**
   * Multi-dimensional signal data.
   *
   * Note that the vector data must be reshaped to get the
   * multi-dimensional array.  In Python, use:
   * a = numpy.array(myStruct.data);
   * a.reshape(myStruct.shape);
   */
  struct BoolSignal {
    /** Array dimensions (shape). */
    DimensionList shape;
    /** Array data, stored as a vector. */
    BoolList data;
    /** Time axis data. */
    TimestampList t;
  };
  /**
   * Multi-dimensional signal data.
   *
   * Note that the vector data must be reshaped to get the
   * multi-dimensional array.  In Python, use:
   * a = numpy.array(myStruct.data);
   * a.reshape(myStruct.shape);
   */
  struct StringSignal {
    /** Array dimensions (shape). */
    DimensionList shape;
    /** Array data, stored as a vector. */
    StringList data;
    /** Time axis data. */
    TimestampList t;
  };
  /**
   * Multi-dimensional signal data.
   *
   * Note that the vector data must be reshaped to get the
   * multi-dimensional array.  In Python, use:
   * a = numpy.array(myStruct.data);
   * a.reshape(myStruct.shape);
   */
  struct Float64Signal {
    /** Array dimensions (shape). */
    DimensionList shape;
    /** Array data, stored as a vector. */
    Float64List data;
    /** Time axis data. */
    TimestampList t;
  };
  /**
   * Multi-dimensional signal data.
   *
   * Note that the vector data must be reshaped to get the
   * multi-dimensional array.  In Python, use:
   * a = numpy.array(myStruct.data);
   * a.reshape(myStruct.shape);
   */
  struct DateSignal {
    /** Array dimensions (shape). */
    DimensionList shape;
    /** Array data, stored as a vector. */
    DateList data;
    /** Time axis data. */
    TimestampList t;
  };
  /**
   * Multi-dimensional signal data.
   *
   * Note that the vector data must be reshaped to get the
   * multi-dimensional array.  In Python, use:
   * a = numpy.array(myStruct.data);
   * a.reshape(myStruct.shape);
   */
  struct TimestampSignal {
    /** Array dimensions (shape). */
    DimensionList shape;
    /** Array data, stored as a vector. */
    TimestampList data;
    /** Time axis data. */
    TimestampList t;
  };
  /**
   * Multi-dimensional signal data.
   *
   * Note that the vector data must be reshaped to get the
   * multi-dimensional array.  In Python, use:
   * a = numpy.array(myStruct.data);
   * a.reshape(myStruct.shape);
   */
  struct Int64Signal {
    /** Array dimensions (shape). */
    DimensionList shape;
    /** Array data, stored as a vector. */
    Int64List data;
    /** Time axis data. */
    TimestampList t;
  };
  /**
   * Multi-dimensional signal data.
   *
   * Note that the vector data must be reshaped to get the
   * multi-dimensional array.  In Python, use:
   * a = numpy.array(myStruct.data);
   * a.reshape(myStruct.shape);
   */
  struct Float32Signal {
    /** Array dimensions (shape). */
    DimensionList shape;
    /** Array data, stored as a vector. */
    Float32List data;
    /** Time axis data. */
    TimestampList t;
  };

  /**
   * Supported material types. 
   */
  enum MaterialType {
    /** Elastic material (default).  */
    MaterialTypeELASTIC,
    /** Orthotropic material.  */
    MaterialTypeORTHOTROPIC,
    /** Nonlinear-elastic material.  */
    MaterialTypeNONLINEARELASTIC,
    /** Plastic bilinear material.  */
    MaterialTypePLASTICBILINEAR,
    /** Plastic muli-linear material.  */
    MaterialTypePLASTICMULTILINEAR,
    /** Thermo isotropic material.  */
    MaterialTypeTHERMOISOTROPIC,
    /** Thermo orthotropic material.  */
    MaterialTypeTHERMOORTHOTROPIC,
  };

  /** Data type for holding list of MaterialTypes. */
  sequence <MaterialType> MaterialTypeList;

  /**
   * Supported units. 
   */
  enum Unit {
    /** Meter (SI) (default).  */
    UnitMETER,
    /** Kilogram (SI).  */
    UnitKILOGRAM,
    /** Metric ton: 1000 Kilogram (SI).  */
    UnitMETRICTON,
    /** Newton (SI).  */
    UnitNEWTON,
    /** Kilo Newton (SI).  */
    UnitKILONEWTON,
    /** Inch (1/12 foot; imperial).  */
    UnitINCH,
    /** Foot (1200/3937 meters; imperial).  */
    UnitFOOT,
    /** Pound (international avoirdupois pound; 0.45359237 kilogram).  */
    UnitPOUND,
    /** 1000 Pounds (imperial).  */
    UnitKILOPOUND,
    /** Mass that accelerates by 1 ft/s^2 (imperial)  */
    UnitSLUG,
    /** 1000 Slugs (imperial).  */
    UnitKILOSLUG,
    /** Mega Joule.  */
    UnitMJ,
    /** US dollar.  */
    UnitMoneyUSD,
  };

  /** Data type for holding list of Units. */
  sequence <Unit> UnitList;

  /**
   * Available quantities (degrees of freedom). 
   */
  enum Quantity {
    /** X displacement (default).  */
    QuantityXDISPLACEMENT,
    /** Y displacement.  */
    QuantityYDISPLACEMENT,
    /** Z displacement.  */
    QuantityZDISPLACEMENT,
    /** X rotation.  */
    QuantityXROTATION,
    /** Y rotation.  */
    QuantityYROTATION,
    /** Z rotation  */
    QuantityZROTATION,
    /** X force  */
    QuantityXFORCE,
    /** Y force  */
    QuantityYFORCE,
    /** Z force  */
    QuantityZFORCE,
    /** Raw (undefined, e.g. internal binary data).  */
    QuantityRAW,
    /** Displacement (undefined direction) [m].  */
    QuantityDISPLACEMENT,
    /** Velocity (undefined direction) [m/s].  */
    QuantityVELOCITY,
    /** Velocity (undefined direction) [m/s^2].  */
    QuantityACCELERATION,
    /** Angle [rad].  */
    QuantityANGLE,
    /** Voltage [V].  */
    QuantityVOLTAGE,
    /** Temperature [C].  */
    QuantityTEMPERATURE,
    /** * Humidity [%].
   *
   * Humidity ranges from 0.0 to 100.0.
    */
    QuantityHUMIDITY,
    /** Strain (undefined direction) [-].  */
    QuantitySTRAIN,
  };

  /** Data type for holding list of Quantitys. */
  sequence <Quantity> QuantityList;

  /**
   * Supported coordinate system types. 
   */
  enum CoordinateSystemType {
    /** Cartesian coordinate system (default)  */
    CoordinateSystemTypeCARTESIAN,
    /** Spherical coordinate system  */
    CoordinateSystemTypeSPHERICAL,
    /** Cylindrical coordinate system  */
    CoordinateSystemTypeCYLINDRICAL,
  };

  /** Data type for holding list of CoordinateSystemTypes. */
  sequence <CoordinateSystemType> CoordinateSystemTypeList;

  /**
   * Supported boundary types. 
   */
  enum BoundaryType {
    /** Free to move (default).  */
    BoundaryTypeFREE,
    /** Fixed.  */
    BoundaryTypeFIXED,
  };

  /** Data type for holding list of BoundaryTypes. */
  sequence <BoundaryType> BoundaryTypeList;

  /**
   * Supported cross sections. 
   */
  enum SectionType {
    /**  */
    SectionTypeBOX,
    /**  */
    SectionTypePROPERTIES,
    /**  */
    SectionTypeRECTANGULAR,
    /**  */
    SectionTypePIPE,
    /**  */
    SectionTypeI,
    /**  */
    SectionTypeL,
    /**  */
    SectionTypeU,
  };

  /** Data type for holding list of SectionTypes. */
  sequence <SectionType> SectionTypeList;

  /**
   * Supported group types. 
   */
  enum GroupType {
    /**  */
    GroupTypeBEAM,
    /**  */
    GroupTypeTRUSS,
    /**  */
    GroupTypeGENERAL,
    /**  */
    GroupTypeISOBEAM,
    /**  */
    GroupTypePLATE,
    /**  */
    GroupTypeSHELL,
    /**  */
    GroupTypeSPRING,
    /**  */
    GroupTypeTHREEDSOLID,
    /**  */
    GroupTypeTWODSOLID,
  };

  /** Data type for holding list of GroupTypes. */
  sequence <GroupType> GroupTypeList;

  /**
   * * Supported sensor types.
 
   */
  enum SensorType {
    /** * Voltage measurement [V].
    */
    SensorTypeVOLTAGE,
    /** * Displacment sensor, measuring linear displacement [m].
    */
    SensorTypeDISPLACEMENT,
    /** * Accelerometer, measuring linear acceleration [m/s^2].
    */
    SensorTypeACCELEROMETER,
    /** * Anemometer, measuring wind speed [m/s].
    */
    SensorTypeANEMOMETER,
    /** * Wind vane, measuring wind direction [rad].
   * 
   * The wind direction is measured as a clock wise angle, where wind
   * coming from the (true) North = 0.0 radians, East = PI/2 radians,
   * South = PI radians, and West = 3/2 PI radians.
    */
    SensorTypeWINDVANE,
    /** * Strain gauge, measuring local strain [-].
    */
    SensorTypeSTRAINGAUGE,
    /** * Thermometer, measuring temperature [C].
    */
    SensorTypeTHERMOMETER,
    /** * Humidity, measuring relative humidity [%].
    */
    SensorTypeHUMIDITY,
  };

  /** Data type for holding list of SensorTypes. */
  sequence <SensorType> SensorTypeList;

  /**
   * Structure materials. 
   */
  enum Material {
    /** Steel.  */
    MaterialSteel,
    /** Concrete material.  */
    MaterialConcrete,
  };

  /** Data type for holding list of Materials. */
  sequence <Material> MaterialList;

  /**
   * Structure component types. 
   */
  enum StructureComponentType {
    /** Deck component.  */
    StructureComponentTypeDeck,
    /** Abutment component.  */
    StructureComponentTypeAbutment,
    /** Pin and hanger component.  */
    StructureComponentTypePinHanger,
    /** Span component.  */
    StructureComponentTypeSpan,
    /** Column component.  */
    StructureComponentTypeColumn,
    /** Girder component.  */
    StructureComponentTypeGirder,
    /** Joint component.  */
    StructureComponentTypeJoint,
    /** Approach component.  */
    StructureComponentTypeApproach,
    /** Composite action component.  */
    StructureComponentTypeCompositeAction,
  };

  /** Data type for holding list of StructureComponentTypes. */
  sequence <StructureComponentType> StructureComponentTypeList;

  /**
   * Supported super structure design types. 
   */
  enum SuperStructureDesignType {
    /** Concrete highway bridge.  */
    SuperStructureDesignTypeConcreteHighwayBridge,
  };

  /** Data type for holding list of SuperStructureDesignTypes. */
  sequence <SuperStructureDesignType> SuperStructureDesignTypeList;

  /**
   * Supported salt usage types. 
   */
  enum SaltUsageLevel {
    /** Default  */
    SaltUsageLevelNone,
  };

  /** Data type for holding list of SaltUsageLevels. */
  sequence <SaltUsageLevel> SaltUsageLevelList;

  /**
   * Supported snow accumulation types. 
   */
  enum SnowAccumulation {
    /** Default  */
    SnowAccumulationNone,
  };

  /** Data type for holding list of SnowAccumulations. */
  sequence <SnowAccumulation> SnowAccumulationList;

  /**
   * Supported simple Koeppen climate groups. 
   */
  enum ClimateGroup {
    /** Tropical climate.  */
    ClimateGroupTropical,
    /** Arid climate.  */
    ClimateGroupArid,
    /** Temperate climate.  */
    ClimateGroupTemperate,
    /** Continental climate.  */
    ClimateGroupContinental,
    /** Polar climate.  */
    ClimateGroupPolar,
  };

  /** Data type for holding list of ClimateGroups. */
  sequence <ClimateGroup> ClimateGroupList;

  /**
   * Supported functional class 
   */
  enum FunctionalClass {
    /** Default  */
    FunctionalClassDefault,
  };

  /** Data type for holding list of FunctionalClasss. */
  sequence <FunctionalClass> FunctionalClassList;

  /**
   * Supported inspection element types. 
   */
  enum InspElementType {
    /** Deck surface.  */
    InspElementTypeDeckSurface,
    /** Deck sidewalk.  */
    InspElementTypeDeckSidewalk,
    /** Deck structure inventory and appraisal.  */
    InspElementTypeDeckSIA,
    /** Span railings.  */
    InspElementTypeSpanRailing,
    /** Span drainage.  */
    InspElementTypeSpanDrainage,
    /** Span paint system inventory and appraisal.  */
    InspElementTypeSpanPaintSIA,
    /** Abutment structure inventory and appraisal.  */
    InspElementTypeAbutmentSIA,
    /** Abutment slope protection.  */
    InspElementTypeAbutmentSlopeProtection,
    /** Pin and hanger bearing.  */
    InspElementTypePinHangerBearing,
    /** Pier structure inventory and appraisal.  */
    InspElementTypeColumnPierSIA,
    /** Stringer structure inventory and appraisal.  */
    InspElementTypeGirderStringerSIA,
    /** Girder section loss.  */
    InspElementTypeGirderSectionLoss,
    /** Expansion joints.  */
    InspElementTypeJointExpansion,
    /** Other joints.  */
    InspElementTypeJointOther,
    /** Approach shoulder.  */
    InspElementTypeApproachShoulder,
    /** Approach pavement.  */
    InspElementTypeApproachPavement,
  };

  /** Data type for holding list of InspElementTypes. */
  sequence <InspElementType> InspElementTypeList;

  /**
   * Supported inspection observation types. 
   */
  enum InspObservationType {
    /** Delamination (default).  */
    InspObservationTypeDelamination,
  };

  /** Data type for holding list of InspObservationTypes. */
  sequence <InspObservationType> InspObservationTypeList;

  /**
   * Environment impact types. 
   */
  enum EnvImpactType {
    /**  */
    EnvImpactTypeEnergy,
    /**  */
    EnvImpactTypeGHG,
    /**  */
    EnvImpactTypeSOx,
    /**  */
    EnvImpactTypeNOx,
    /**  */
    EnvImpactTypePM,
    /**  */
    EnvImpactTypeCarcinogens,
    /**  */
    EnvImpactTypeNMHC,
    /**  */
    EnvImpactTypeCO,
    /**  */
    EnvImpactTypeOZONEDEP,
    /**  */
    EnvImpactTypeEUTPOT,
    /**  */
    EnvImpactTypeHEAVYMET,
    /**  */
    EnvImpactTypeSUMSMOG,
    /**  */
    EnvImpactTypeWINSMOG,
    /**  */
    EnvImpactTypeSOLWASTE,
    /**  */
    EnvImpactTypeCOST,
  };

  /** Data type for holding list of EnvImpactTypes. */
  sequence <EnvImpactType> EnvImpactTypeList;

  /**
   * 
   */
  enum OptimizationObjective {
    /**  */
    OptimizationObjectiveGlobalWarming,
    /**  */
    OptimizationObjectiveOzoneDepletionPotential,
    /**  */
    OptimizationObjectiveAcidificationPotential,
    /**  */
    OptimizationObjectiveEutriphicationPotential,
    /**  */
    OptimizationObjectiveHeavyMetal,
    /**  */
    OptimizationObjectiveCarcinogens,
    /**  */
    OptimizationObjectiveSummerSmog,
    /**  */
    OptimizationObjectiveWinterSmog,
    /**  */
    OptimizationObjectiveEnergyResources,
    /**  */
    OptimizationObjectiveSolidWaste,
    /**  */
    OptimizationObjectiveCost,
  };

  /** Data type for holding list of OptimizationObjectives. */
  sequence <OptimizationObjective> OptimizationObjectiveList;

  /**
   * Component repair options. 
   */
  enum ComponentRepairOption {
    /** Deck Patching.  */
    ComponentRepairOptionCrewRep01,
    /** Approach Pavement.  */
    ComponentRepairOptionCrewRep02,
    /** Joint Repair.  */
    ComponentRepairOptionCrewRep03,
    /** Railing Repair.  */
    ComponentRepairOptionCrewRep04,
    /** Detailed Inspection.  */
    ComponentRepairOptionCrewRep05,
    /** Zone Painting.  */
    ComponentRepairOptionCrewRep06,
    /** Substructure Repair.  */
    ComponentRepairOptionCrewRep07,
    /** Slope Repair.  */
    ComponentRepairOptionCrewRep08,
    /** Brush Cut.  */
    ComponentRepairOptionCrewRep09,
    /** Sound Fascia and Remove Loose Concrete.  */
    ComponentRepairOptionCrewRep10,
    /** Clean and Paint Pin and Hanger.  */
    ComponentRepairOptionCrewRep11,
    /** Patch Concrete Barrier and Seal Cracks.  */
    ComponentRepairOptionCrewRep12,
    /** Clear Rebar and Patch/Repair Concrete in Barrier.  */
    ComponentRepairOptionCrewRep13,
    /** Replace Rebar and Patch/Repair Concrete in Barrier.  */
    ComponentRepairOptionCrewRep14,
    /** Concrete Deck Crack Sealing.  */
    ComponentRepairOptionCrewRep15,
    /** Concrete Deck Patching.  */
    ComponentRepairOptionCrewRep16,
    /** Epoxy Deck Overlay.  */
    ComponentRepairOptionCrewRep17,
    /** HMA Overlay with HMA Waterproofing Membrane.  */
    ComponentRepairOptionCrewRep18,
    /** HMA Overlay with No HMA Waterproofing Membrane.  */
    ComponentRepairOptionCrewRep19,
    /** Concrete Deck Overlay Shallow.  */
    ComponentRepairOptionCrewRep20,
    /** Concrete Deck Overlay.  */
    ComponentRepairOptionCrewRep21,
    /** Strip Seal Joint Repair.  */
    ComponentRepairOptionCrewRep22,
    /** Pourable Joint Seal Repair.  */
    ComponentRepairOptionCrewRep23,
    /** Pourable Joint Seal Replacement.  */
    ComponentRepairOptionCrewRep24,
    /** Compression Joint Seal Repair.  */
    ComponentRepairOptionCrewRep25,
    /** Compression Joint Seal Replacement.  */
    ComponentRepairOptionCrewRep26,
    /** Assembly Joint Seal (Modular) Repair.  */
    ComponentRepairOptionCrewRep27,
    /** Assembly Joint Seal (Modular) Replacement.  */
    ComponentRepairOptionCrewRep28,
    /** Steel Armor Expansion Joints (Open) Repair.  */
    ComponentRepairOptionCrewRep29,
    /** Steel Armor Expansion Joints (Open) Replacement.  */
    ComponentRepairOptionCrewRep30,
    /** Polymer Block Out Expansion Joint Repair.  */
    ComponentRepairOptionCrewRep31,
    /** Polymer Block Out Expansion Joint Replacement.  */
    ComponentRepairOptionCrewRep32,
    /** Block Out Expansion Joint Repair.  */
    ComponentRepairOptionCrewRep33,
    /** Block Out Expansion Joint Replacement.  */
    ComponentRepairOptionCrewRep34,
    /** Superstructure Washing.  */
    ComponentRepairOptionCrewRep35,
    /** Concrete Surface Washing.  */
    ComponentRepairOptionCrewRep36,
    /** Spot Painting.  */
    ComponentRepairOptionCrewRep37,
    /** Substructure Concrete Sealing.  */
    ComponentRepairOptionCrewRep38,
    /** Substructure Concrete Surface Painting.  */
    ComponentRepairOptionCrewRep39,
    /** Substructure Concrete Patching and Repair.  */
    ComponentRepairOptionCrewRep40,
    /** Scour Countermeasures.  */
    ComponentRepairOptionCrewRep41,
    /** Drainage System Cleaning.  */
    ComponentRepairOptionCrewRep42,
    /** Approach Pavement Relief Joints.  */
    ComponentRepairOptionCrewRep43,
    /** Slope Paving Repair.  */
    ComponentRepairOptionCrewRep44,
    /** Strip Seal Joint Replacement.  */
    ComponentRepairOptionCrewRep45,
    /** Bridge Replacement.  */
    ComponentRepairOptionCrewRep46,
    /** Superstructure Replacement.  */
    ComponentRepairOptionCrewRep47,
    /** Substructure Replacement.  */
    ComponentRepairOptionCrewRep48,
    /** Deck Replacement.  */
    ComponentRepairOptionCrewRep49,
    /** Bridge Widening.  */
    ComponentRepairOptionCrewRep50,
    /** Pin and Hanger Replacement.  */
    ComponentRepairOptionCrewRep51,
  };

  /** Data type for holding list of ComponentRepairOptions. */
  sequence <ComponentRepairOption> ComponentRepairOptionList;

  /**
   * Compass directions. 
   */
  enum CompassDirection {
    /**  */
    CompassDirectionNORTH,
    /**  */
    CompassDirectionNORTHEAST,
    /**  */
    CompassDirectionEAST,
    /**  */
    CompassDirectionSOUTHEAST,
    /**  */
    CompassDirectionSOUTH,
    /**  */
    CompassDirectionSOUTHWEST,
    /**  */
    CompassDirectionWEST,
    /**  */
    CompassDirectionNORTHWEST,
  };

  /** Data type for holding list of CompassDirections. */
  sequence <CompassDirection> CompassDirectionList;

  /** UserGroup object proxy. */
  interface UserGroup;
  /** Data type for holding a list of UserGroup proxies. */
  sequence<UserGroup*> UserGroupList;

  /** User object proxy. */
  interface User;
  /** Data type for holding a list of User proxies. */
  sequence<User*> UserList;

  /** UserGroupMembership object proxy. */
  interface UserGroupMembership;
  /** Data type for holding a list of UserGroupMembership proxies. */
  sequence<UserGroupMembership*> UserGroupMembershipList;

  /** NotificationCategory object proxy. */
  interface NotificationCategory;
  /** Data type for holding a list of NotificationCategory proxies. */
  sequence<NotificationCategory*> NotificationCategoryList;

  /** NotificationMembership object proxy. */
  interface NotificationMembership;
  /** Data type for holding a list of NotificationMembership proxies. */
  sequence<NotificationMembership*> NotificationMembershipList;

  /** StructureOwner object proxy. */
  interface StructureOwner;
  /** Data type for holding a list of StructureOwner proxies. */
  sequence<StructureOwner*> StructureOwnerList;

  /** Structure object proxy. */
  interface Structure;
  /** Data type for holding a list of Structure proxies. */
  sequence<Structure*> StructureList;

  /** FEMDof object proxy. */
  interface FEMDof;
  /** Data type for holding a list of FEMDof proxies. */
  sequence<FEMDof*> FEMDofList;

  /** FEMNodalMass object proxy. */
  interface FEMNodalMass;
  /** Data type for holding a list of FEMNodalMass proxies. */
  sequence<FEMNodalMass*> FEMNodalMassList;

  /** FEMNLElasticStrainStress object proxy. */
  interface FEMNLElasticStrainStress;
  /** Data type for holding a list of FEMNLElasticStrainStress proxies. */
  sequence<FEMNLElasticStrainStress*> FEMNLElasticStrainStressList;

  /** FEMBoundary object proxy. */
  interface FEMBoundary;
  /** Data type for holding a list of FEMBoundary proxies. */
  sequence<FEMBoundary*> FEMBoundaryList;

  /** FEMSectionPipe object proxy. */
  interface FEMSectionPipe;
  /** Data type for holding a list of FEMSectionPipe proxies. */
  sequence<FEMSectionPipe*> FEMSectionPipeList;

  /** FEMCoordSystem object proxy. */
  interface FEMCoordSystem;
  /** Data type for holding a list of FEMCoordSystem proxies. */
  sequence<FEMCoordSystem*> FEMCoordSystemList;

  /** FEMNode object proxy. */
  interface FEMNode;
  /** Data type for holding a list of FEMNode proxies. */
  sequence<FEMNode*> FEMNodeList;

  /** FEMTruss object proxy. */
  interface FEMTruss;
  /** Data type for holding a list of FEMTruss proxies. */
  sequence<FEMTruss*> FEMTrussList;

  /** FEMTimeFunctionData object proxy. */
  interface FEMTimeFunctionData;
  /** Data type for holding a list of FEMTimeFunctionData proxies. */
  sequence<FEMTimeFunctionData*> FEMTimeFunctionDataList;

  /** FEMPlasticMlMaterials object proxy. */
  interface FEMPlasticMlMaterials;
  /** Data type for holding a list of FEMPlasticMlMaterials proxies. */
  sequence<FEMPlasticMlMaterials*> FEMPlasticMlMaterialsList;

  /** FEMPlateGroup object proxy. */
  interface FEMPlateGroup;
  /** Data type for holding a list of FEMPlateGroup proxies. */
  sequence<FEMPlateGroup*> FEMPlateGroupList;

  /** FEMBeam object proxy. */
  interface FEMBeam;
  /** Data type for holding a list of FEMBeam proxies. */
  sequence<FEMBeam*> FEMBeamList;

  /** FEMCurvMomentData object proxy. */
  interface FEMCurvMomentData;
  /** Data type for holding a list of FEMCurvMomentData proxies. */
  sequence<FEMCurvMomentData*> FEMCurvMomentDataList;

  /** FEMPropertysets object proxy. */
  interface FEMPropertysets;
  /** Data type for holding a list of FEMPropertysets proxies. */
  sequence<FEMPropertysets*> FEMPropertysetsList;

  /** FEMOrthotropicMaterial object proxy. */
  interface FEMOrthotropicMaterial;
  /** Data type for holding a list of FEMOrthotropicMaterial proxies. */
  sequence<FEMOrthotropicMaterial*> FEMOrthotropicMaterialList;

  /** FEMAppliedLoads object proxy. */
  interface FEMAppliedLoads;
  /** Data type for holding a list of FEMAppliedLoads proxies. */
  sequence<FEMAppliedLoads*> FEMAppliedLoadsList;

  /** FEMThermoOrthData object proxy. */
  interface FEMThermoOrthData;
  /** Data type for holding a list of FEMThermoOrthData proxies. */
  sequence<FEMThermoOrthData*> FEMThermoOrthDataList;

  /** FEMContactPairs object proxy. */
  interface FEMContactPairs;
  /** Data type for holding a list of FEMContactPairs proxies. */
  sequence<FEMContactPairs*> FEMContactPairsList;

  /** FEMGeneral object proxy. */
  interface FEMGeneral;
  /** Data type for holding a list of FEMGeneral proxies. */
  sequence<FEMGeneral*> FEMGeneralList;

  /** FEMBeamGroup object proxy. */
  interface FEMBeamGroup;
  /** Data type for holding a list of FEMBeamGroup proxies. */
  sequence<FEMBeamGroup*> FEMBeamGroupList;

  /** FEMSectionRect object proxy. */
  interface FEMSectionRect;
  /** Data type for holding a list of FEMSectionRect proxies. */
  sequence<FEMSectionRect*> FEMSectionRectList;

  /** FEMBeamLoad object proxy. */
  interface FEMBeamLoad;
  /** Data type for holding a list of FEMBeamLoad proxies. */
  sequence<FEMBeamLoad*> FEMBeamLoadList;

  /** FEMLoadMassProportional object proxy. */
  interface FEMLoadMassProportional;
  /** Data type for holding a list of FEMLoadMassProportional proxies. */
  sequence<FEMLoadMassProportional*> FEMLoadMassProportionalList;

  /** FEMLink object proxy. */
  interface FEMLink;
  /** Data type for holding a list of FEMLink proxies. */
  sequence<FEMLink*> FEMLinkList;

  /** FEMAxesNode object proxy. */
  interface FEMAxesNode;
  /** Data type for holding a list of FEMAxesNode proxies. */
  sequence<FEMAxesNode*> FEMAxesNodeList;

  /** FEMNMTimeMass object proxy. */
  interface FEMNMTimeMass;
  /** Data type for holding a list of FEMNMTimeMass proxies. */
  sequence<FEMNMTimeMass*> FEMNMTimeMassList;

  /** FEMAppliedDisplacement object proxy. */
  interface FEMAppliedDisplacement;
  /** Data type for holding a list of FEMAppliedDisplacement proxies. */
  sequence<FEMAppliedDisplacement*> FEMAppliedDisplacementList;

  /** FEMTimeFunctions object proxy. */
  interface FEMTimeFunctions;
  /** Data type for holding a list of FEMTimeFunctions proxies. */
  sequence<FEMTimeFunctions*> FEMTimeFunctionsList;

  /** FEMForceStrainData object proxy. */
  interface FEMForceStrainData;
  /** Data type for holding a list of FEMForceStrainData proxies. */
  sequence<FEMForceStrainData*> FEMForceStrainDataList;

  /** FEMSkewDOF object proxy. */
  interface FEMSkewDOF;
  /** Data type for holding a list of FEMSkewDOF proxies. */
  sequence<FEMSkewDOF*> FEMSkewDOFList;

  /** FEMSectionI object proxy. */
  interface FEMSectionI;
  /** Data type for holding a list of FEMSectionI proxies. */
  sequence<FEMSectionI*> FEMSectionIList;

  /** FEMPlasticBilinearMaterial object proxy. */
  interface FEMPlasticBilinearMaterial;
  /** Data type for holding a list of FEMPlasticBilinearMaterial proxies. */
  sequence<FEMPlasticBilinearMaterial*> FEMPlasticBilinearMaterialList;

  /** FEMMTForceData object proxy. */
  interface FEMMTForceData;
  /** Data type for holding a list of FEMMTForceData proxies. */
  sequence<FEMMTForceData*> FEMMTForceDataList;

  /** FEMShellPressure object proxy. */
  interface FEMShellPressure;
  /** Data type for holding a list of FEMShellPressure proxies. */
  sequence<FEMShellPressure*> FEMShellPressureList;

  /** FEMMatrices object proxy. */
  interface FEMMatrices;
  /** Data type for holding a list of FEMMatrices proxies. */
  sequence<FEMMatrices*> FEMMatricesList;

  /** FEMDamping object proxy. */
  interface FEMDamping;
  /** Data type for holding a list of FEMDamping proxies. */
  sequence<FEMDamping*> FEMDampingList;

  /** FEMMaterial object proxy. */
  interface FEMMaterial;
  /** Data type for holding a list of FEMMaterial proxies. */
  sequence<FEMMaterial*> FEMMaterialList;

  /** FEMMatrixData object proxy. */
  interface FEMMatrixData;
  /** Data type for holding a list of FEMMatrixData proxies. */
  sequence<FEMMatrixData*> FEMMatrixDataList;

  /** FEMShellAxesOrtho object proxy. */
  interface FEMShellAxesOrtho;
  /** Data type for holding a list of FEMShellAxesOrtho proxies. */
  sequence<FEMShellAxesOrtho*> FEMShellAxesOrthoList;

  /** FEMEndRelease object proxy. */
  interface FEMEndRelease;
  /** Data type for holding a list of FEMEndRelease proxies. */
  sequence<FEMEndRelease*> FEMEndReleaseList;

  /** FEMTrussGroup object proxy. */
  interface FEMTrussGroup;
  /** Data type for holding a list of FEMTrussGroup proxies. */
  sequence<FEMTrussGroup*> FEMTrussGroupList;

  /** FEMInitialTemperature object proxy. */
  interface FEMInitialTemperature;
  /** Data type for holding a list of FEMInitialTemperature proxies. */
  sequence<FEMInitialTemperature*> FEMInitialTemperatureList;

  /** FEMThermoIsoMaterials object proxy. */
  interface FEMThermoIsoMaterials;
  /** Data type for holding a list of FEMThermoIsoMaterials proxies. */
  sequence<FEMThermoIsoMaterials*> FEMThermoIsoMaterialsList;

  /** FEMThermoIsoData object proxy. */
  interface FEMThermoIsoData;
  /** Data type for holding a list of FEMThermoIsoData proxies. */
  sequence<FEMThermoIsoData*> FEMThermoIsoDataList;

  /** FEMContactGroup3 object proxy. */
  interface FEMContactGroup3;
  /** Data type for holding a list of FEMContactGroup3 proxies. */
  sequence<FEMContactGroup3*> FEMContactGroup3List;

  /** FEMNLElasticMaterials object proxy. */
  interface FEMNLElasticMaterials;
  /** Data type for holding a list of FEMNLElasticMaterials proxies. */
  sequence<FEMNLElasticMaterials*> FEMNLElasticMaterialsList;

  /** FEMPlate object proxy. */
  interface FEMPlate;
  /** Data type for holding a list of FEMPlate proxies. */
  sequence<FEMPlate*> FEMPlateList;

  /** FEMIsoBeam object proxy. */
  interface FEMIsoBeam;
  /** Data type for holding a list of FEMIsoBeam proxies. */
  sequence<FEMIsoBeam*> FEMIsoBeamList;

  /** FEMAppliedConcentratedLoad object proxy. */
  interface FEMAppliedConcentratedLoad;
  /** Data type for holding a list of FEMAppliedConcentratedLoad proxies. */
  sequence<FEMAppliedConcentratedLoad*> FEMAppliedConcentratedLoadList;

  /** FEMTwoDSolidGroup object proxy. */
  interface FEMTwoDSolidGroup;
  /** Data type for holding a list of FEMTwoDSolidGroup proxies. */
  sequence<FEMTwoDSolidGroup*> FEMTwoDSolidGroupList;

  /** FEMGroup object proxy. */
  interface FEMGroup;
  /** Data type for holding a list of FEMGroup proxies. */
  sequence<FEMGroup*> FEMGroupList;

  /** FEMProperties object proxy. */
  interface FEMProperties;
  /** Data type for holding a list of FEMProperties proxies. */
  sequence<FEMProperties*> FEMPropertiesList;

  /** FEMThreeDSolidGroup object proxy. */
  interface FEMThreeDSolidGroup;
  /** Data type for holding a list of FEMThreeDSolidGroup proxies. */
  sequence<FEMThreeDSolidGroup*> FEMThreeDSolidGroupList;

  /** FEMThreeDSolid object proxy. */
  interface FEMThreeDSolid;
  /** Data type for holding a list of FEMThreeDSolid proxies. */
  sequence<FEMThreeDSolid*> FEMThreeDSolidList;

  /** FEMSectionProp object proxy. */
  interface FEMSectionProp;
  /** Data type for holding a list of FEMSectionProp proxies. */
  sequence<FEMSectionProp*> FEMSectionPropList;

  /** FEMElasticMaterial object proxy. */
  interface FEMElasticMaterial;
  /** Data type for holding a list of FEMElasticMaterial proxies. */
  sequence<FEMElasticMaterial*> FEMElasticMaterialList;

  /** FEMPoints object proxy. */
  interface FEMPoints;
  /** Data type for holding a list of FEMPoints proxies. */
  sequence<FEMPoints*> FEMPointsList;

  /** FEMThermoOrthMaterials object proxy. */
  interface FEMThermoOrthMaterials;
  /** Data type for holding a list of FEMThermoOrthMaterials proxies. */
  sequence<FEMThermoOrthMaterials*> FEMThermoOrthMaterialsList;

  /** FEMConstraints object proxy. */
  interface FEMConstraints;
  /** Data type for holding a list of FEMConstraints proxies. */
  sequence<FEMConstraints*> FEMConstraintsList;

  /** FEMMCrigidities object proxy. */
  interface FEMMCrigidities;
  /** Data type for holding a list of FEMMCrigidities proxies. */
  sequence<FEMMCrigidities*> FEMMCrigiditiesList;

  /** FEMSkeySysNode object proxy. */
  interface FEMSkeySysNode;
  /** Data type for holding a list of FEMSkeySysNode proxies. */
  sequence<FEMSkeySysNode*> FEMSkeySysNodeList;

  /** FEMIsoBeamGroup object proxy. */
  interface FEMIsoBeamGroup;
  /** Data type for holding a list of FEMIsoBeamGroup proxies. */
  sequence<FEMIsoBeamGroup*> FEMIsoBeamGroupList;

  /** FEMShellDOF object proxy. */
  interface FEMShellDOF;
  /** Data type for holding a list of FEMShellDOF proxies. */
  sequence<FEMShellDOF*> FEMShellDOFList;

  /** FEMCrossSection object proxy. */
  interface FEMCrossSection;
  /** Data type for holding a list of FEMCrossSection proxies. */
  sequence<FEMCrossSection*> FEMCrossSectionList;

  /** FEMTwistMomentData object proxy. */
  interface FEMTwistMomentData;
  /** Data type for holding a list of FEMTwistMomentData proxies. */
  sequence<FEMTwistMomentData*> FEMTwistMomentDataList;

  /** FEMShell object proxy. */
  interface FEMShell;
  /** Data type for holding a list of FEMShell proxies. */
  sequence<FEMShell*> FEMShellList;

  /** FEMNTNContact object proxy. */
  interface FEMNTNContact;
  /** Data type for holding a list of FEMNTNContact proxies. */
  sequence<FEMNTNContact*> FEMNTNContactList;

  /** FEMShellLayer object proxy. */
  interface FEMShellLayer;
  /** Data type for holding a list of FEMShellLayer proxies. */
  sequence<FEMShellLayer*> FEMShellLayerList;

  /** FEMSkewSysAngles object proxy. */
  interface FEMSkewSysAngles;
  /** Data type for holding a list of FEMSkewSysAngles proxies. */
  sequence<FEMSkewSysAngles*> FEMSkewSysAnglesList;

  /** FEMGroundMotionRecord object proxy. */
  interface FEMGroundMotionRecord;
  /** Data type for holding a list of FEMGroundMotionRecord proxies. */
  sequence<FEMGroundMotionRecord*> FEMGroundMotionRecordList;

  /** FEMGeneralGroup object proxy. */
  interface FEMGeneralGroup;
  /** Data type for holding a list of FEMGeneralGroup proxies. */
  sequence<FEMGeneralGroup*> FEMGeneralGroupList;

  /** FEMTwoDSolid object proxy. */
  interface FEMTwoDSolid;
  /** Data type for holding a list of FEMTwoDSolid proxies. */
  sequence<FEMTwoDSolid*> FEMTwoDSolidList;

  /** FEMAppliedTemperature object proxy. */
  interface FEMAppliedTemperature;
  /** Data type for holding a list of FEMAppliedTemperature proxies. */
  sequence<FEMAppliedTemperature*> FEMAppliedTemperatureList;

  /** FEMMatrixSets object proxy. */
  interface FEMMatrixSets;
  /** Data type for holding a list of FEMMatrixSets proxies. */
  sequence<FEMMatrixSets*> FEMMatrixSetsList;

  /** FEMConstraintCoef object proxy. */
  interface FEMConstraintCoef;
  /** Data type for holding a list of FEMConstraintCoef proxies. */
  sequence<FEMConstraintCoef*> FEMConstraintCoefList;

  /** FEMSectionBox object proxy. */
  interface FEMSectionBox;
  /** Data type for holding a list of FEMSectionBox proxies. */
  sequence<FEMSectionBox*> FEMSectionBoxList;

  /** FEMNKDisplForce object proxy. */
  interface FEMNKDisplForce;
  /** Data type for holding a list of FEMNKDisplForce proxies. */
  sequence<FEMNKDisplForce*> FEMNKDisplForceList;

  /** FEMPlasticStrainStress object proxy. */
  interface FEMPlasticStrainStress;
  /** Data type for holding a list of FEMPlasticStrainStress proxies. */
  sequence<FEMPlasticStrainStress*> FEMPlasticStrainStressList;

  /** FEMShellAxesOrthoData object proxy. */
  interface FEMShellAxesOrthoData;
  /** Data type for holding a list of FEMShellAxesOrthoData proxies. */
  sequence<FEMShellAxesOrthoData*> FEMShellAxesOrthoDataList;

  /** FEMGeneralNode object proxy. */
  interface FEMGeneralNode;
  /** Data type for holding a list of FEMGeneralNode proxies. */
  sequence<FEMGeneralNode*> FEMGeneralNodeList;

  /** FEMStrLines object proxy. */
  interface FEMStrLines;
  /** Data type for holding a list of FEMStrLines proxies. */
  sequence<FEMStrLines*> FEMStrLinesList;

  /** FEMContactSurface object proxy. */
  interface FEMContactSurface;
  /** Data type for holding a list of FEMContactSurface proxies. */
  sequence<FEMContactSurface*> FEMContactSurfaceList;

  /** FEMMCForceData object proxy. */
  interface FEMMCForceData;
  /** Data type for holding a list of FEMMCForceData proxies. */
  sequence<FEMMCForceData*> FEMMCForceDataList;

  /** FEMSpring object proxy. */
  interface FEMSpring;
  /** Data type for holding a list of FEMSpring proxies. */
  sequence<FEMSpring*> FEMSpringList;

  /** FEMSpringGroup object proxy. */
  interface FEMSpringGroup;
  /** Data type for holding a list of FEMSpringGroup proxies. */
  sequence<FEMSpringGroup*> FEMSpringGroupList;

  /** FEMShellGroup object proxy. */
  interface FEMShellGroup;
  /** Data type for holding a list of FEMShellGroup proxies. */
  sequence<FEMShellGroup*> FEMShellGroupList;

  /** DaqUnit object proxy. */
  interface DaqUnit;
  /** Data type for holding a list of DaqUnit proxies. */
  sequence<DaqUnit*> DaqUnitList;

  /** DaqUnitChannel object proxy. */
  interface DaqUnitChannel;
  /** Data type for holding a list of DaqUnitChannel proxies. */
  sequence<DaqUnitChannel*> DaqUnitChannelList;

  /** Sensor object proxy. */
  interface Sensor;
  /** Data type for holding a list of Sensor proxies. */
  sequence<Sensor*> SensorList;

  /** SensorChannel object proxy. */
  interface SensorChannel;
  /** Data type for holding a list of SensorChannel proxies. */
  sequence<SensorChannel*> SensorChannelList;

  /** SensorChannelConnection object proxy. */
  interface SensorChannelConnection;
  /** Data type for holding a list of SensorChannelConnection proxies. */
  sequence<SensorChannelConnection*> SensorChannelConnectionList;

  /** FixedCamera object proxy. */
  interface FixedCamera;
  /** Data type for holding a list of FixedCamera proxies. */
  sequence<FixedCamera*> FixedCameraList;

  /** BridgeDetails object proxy. */
  interface BridgeDetails;
  /** Data type for holding a list of BridgeDetails proxies. */
  sequence<BridgeDetails*> BridgeDetailsList;

  /** FacilityRoad object proxy. */
  interface FacilityRoad;
  /** Data type for holding a list of FacilityRoad proxies. */
  sequence<FacilityRoad*> FacilityRoadList;

  /** FacilityRailway object proxy. */
  interface FacilityRailway;
  /** Data type for holding a list of FacilityRailway proxies. */
  sequence<FacilityRailway*> FacilityRailwayList;

  /** FeatureRoad object proxy. */
  interface FeatureRoad;
  /** Data type for holding a list of FeatureRoad proxies. */
  sequence<FeatureRoad*> FeatureRoadList;

  /** FeatureRailway object proxy. */
  interface FeatureRailway;
  /** Data type for holding a list of FeatureRailway proxies. */
  sequence<FeatureRailway*> FeatureRailwayList;

  /** FeatureRiver object proxy. */
  interface FeatureRiver;
  /** Data type for holding a list of FeatureRiver proxies. */
  sequence<FeatureRiver*> FeatureRiverList;

  /** Road object proxy. */
  interface Road;
  /** Data type for holding a list of Road proxies. */
  sequence<Road*> RoadList;

  /** Railway object proxy. */
  interface Railway;
  /** Data type for holding a list of Railway proxies. */
  sequence<Railway*> RailwayList;

  /** River object proxy. */
  interface River;
  /** Data type for holding a list of River proxies. */
  sequence<River*> RiverList;

  /** BridgeInspection object proxy. */
  interface BridgeInspection;
  /** Data type for holding a list of BridgeInspection proxies. */
  sequence<BridgeInspection*> BridgeInspectionList;

  /** Inspector object proxy. */
  interface Inspector;
  /** Data type for holding a list of Inspector proxies. */
  sequence<Inspector*> InspectorList;

  /** InspectionAgency object proxy. */
  interface InspectionAgency;
  /** Data type for holding a list of InspectionAgency proxies. */
  sequence<InspectionAgency*> InspectionAgencyList;

  /** StructureAssessment object proxy. */
  interface StructureAssessment;
  /** Data type for holding a list of StructureAssessment proxies. */
  sequence<StructureAssessment*> StructureAssessmentList;

  /** StructureRetrofit object proxy. */
  interface StructureRetrofit;
  /** Data type for holding a list of StructureRetrofit proxies. */
  sequence<StructureRetrofit*> StructureRetrofitList;

  /** PontisElement object proxy. */
  interface PontisElement;
  /** Data type for holding a list of PontisElement proxies. */
  sequence<PontisElement*> PontisElementList;

  /** StructureComponent object proxy. */
  interface StructureComponent;
  /** Data type for holding a list of StructureComponent proxies. */
  sequence<StructureComponent*> StructureComponentList;

  /** ComponentInspElement object proxy. */
  interface ComponentInspElement;
  /** Data type for holding a list of ComponentInspElement proxies. */
  sequence<ComponentInspElement*> ComponentInspElementList;

  /** StructureComponentGroups object proxy. */
  interface StructureComponentGroups;
  /** Data type for holding a list of StructureComponentGroups proxies. */
  sequence<StructureComponentGroups*> StructureComponentGroupsList;

  /** StructureComponentReliability object proxy. */
  interface StructureComponentReliability;
  /** Data type for holding a list of StructureComponentReliability proxies. */
  sequence<StructureComponentReliability*> StructureComponentReliabilityList;

  /** StructureComponentAssessment object proxy. */
  interface StructureComponentAssessment;
  /** Data type for holding a list of StructureComponentAssessment proxies. */
  sequence<StructureComponentAssessment*> StructureComponentAssessmentList;

  /** StructureComponentRating object proxy. */
  interface StructureComponentRating;
  /** Data type for holding a list of StructureComponentRating proxies. */
  sequence<StructureComponentRating*> StructureComponentRatingList;

  /** StructureComponentRepairOption object proxy. */
  interface StructureComponentRepairOption;
  /** Data type for holding a list of StructureComponentRepairOption proxies. */
  sequence<StructureComponentRepairOption*> StructureComponentRepairOptionList;

  /** StructureTraffic object proxy. */
  interface StructureTraffic;
  /** Data type for holding a list of StructureTraffic proxies. */
  sequence<StructureTraffic*> StructureTrafficList;

  /** StructureComponentRepair object proxy. */
  interface StructureComponentRepair;
  /** Data type for holding a list of StructureComponentRepair proxies. */
  sequence<StructureComponentRepair*> StructureComponentRepairList;

  /** ComponentInspElementAssessment object proxy. */
  interface ComponentInspElementAssessment;
  /** Data type for holding a list of ComponentInspElementAssessment proxies. */
  sequence<ComponentInspElementAssessment*> ComponentInspElementAssessmentList;

  /** InspectionMultimedia object proxy. */
  interface InspectionMultimedia;
  /** Data type for holding a list of InspectionMultimedia proxies. */
  sequence<InspectionMultimedia*> InspectionMultimediaList;

  /** BridgeInspectionMultimedia object proxy. */
  interface BridgeInspectionMultimedia;
  /** Data type for holding a list of BridgeInspectionMultimedia proxies. */
  sequence<BridgeInspectionMultimedia*> BridgeInspectionMultimediaList;

  /** ComponentInspectionMultimedia object proxy. */
  interface ComponentInspectionMultimedia;
  /** Data type for holding a list of ComponentInspectionMultimedia proxies. */
  sequence<ComponentInspectionMultimedia*> ComponentInspectionMultimediaList;

  /** ElementInspectionMultimedia object proxy. */
  interface ElementInspectionMultimedia;
  /** Data type for holding a list of ElementInspectionMultimedia proxies. */
  sequence<ElementInspectionMultimedia*> ElementInspectionMultimediaList;

  /** InspectionObservation object proxy. */
  interface InspectionObservation;
  /** Data type for holding a list of InspectionObservation proxies. */
  sequence<InspectionObservation*> InspectionObservationList;

  /** InspectionMultimediaTags object proxy. */
  interface InspectionMultimediaTags;
  /** Data type for holding a list of InspectionMultimediaTags proxies. */
  sequence<InspectionMultimediaTags*> InspectionMultimediaTagsList;

  /** StructureComponentPoint object proxy. */
  interface StructureComponentPoint;
  /** Data type for holding a list of StructureComponentPoint proxies. */
  sequence<StructureComponentPoint*> StructureComponentPointList;

  /** StructureComponentCADModel object proxy. */
  interface StructureComponentCADModel;
  /** Data type for holding a list of StructureComponentCADModel proxies. */
  sequence<StructureComponentCADModel*> StructureComponentCADModelList;

  /** CompRepairFinalCond object proxy. */
  interface CompRepairFinalCond;
  /** Data type for holding a list of CompRepairFinalCond proxies. */
  sequence<CompRepairFinalCond*> CompRepairFinalCondList;

  /** CompRepairTimelineMatrix object proxy. */
  interface CompRepairTimelineMatrix;
  /** Data type for holding a list of CompRepairTimelineMatrix proxies. */
  sequence<CompRepairTimelineMatrix*> CompRepairTimelineMatrixList;

  /** CompEnvBurdenMatrix object proxy. */
  interface CompEnvBurdenMatrix;
  /** Data type for holding a list of CompEnvBurdenMatrix proxies. */
  sequence<CompEnvBurdenMatrix*> CompEnvBurdenMatrixList;

  /** WeighInMotionStation object proxy. */
  interface WeighInMotionStation;
  /** Data type for holding a list of WeighInMotionStation proxies. */
  sequence<WeighInMotionStation*> WeighInMotionStationList;

  /** WeighInMotionSensorData object proxy. */
  interface WeighInMotionSensorData;
  /** Data type for holding a list of WeighInMotionSensorData proxies. */
  sequence<WeighInMotionSensorData*> WeighInMotionSensorDataList;

  /** MappingMatrix object proxy. */
  interface MappingMatrix;
  /** Data type for holding a list of MappingMatrix proxies. */
  sequence<MappingMatrix*> MappingMatrixList;

  /** MeasurementCycle object proxy. */
  interface MeasurementCycle;
  /** Data type for holding a list of MeasurementCycle proxies. */
  sequence<MeasurementCycle*> MeasurementCycleList;

  /** StaticLoadToSensorMapping object proxy. */
  interface StaticLoadToSensorMapping;
  /** Data type for holding a list of StaticLoadToSensorMapping proxies. */
  sequence<StaticLoadToSensorMapping*> StaticLoadToSensorMappingList;

  /** DaqUnitChannelData object proxy. */
  interface DaqUnitChannelData;
  /** Data type for holding a list of DaqUnitChannelData proxies. */
  sequence<DaqUnitChannelData*> DaqUnitChannelDataList;

  /** SensorChannelData object proxy. */
  interface SensorChannelData;
  /** Data type for holding a list of SensorChannelData proxies. */
  sequence<SensorChannelData*> SensorChannelDataList;

  /**
   * UserGroup fields structure.
   */
  struct UserGroupFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    string mName;
  };
  /** Data type for holding a list of UserGroup fields structures. */
  sequence<UserGroupFields> UserGroupFieldsList;

  /**
   * User fields structure.
   */
  struct UserFields {
    /** Unique identifier (for internal use only). */
    long id;
    /** User name (last name, first name(s)).  */
    string mUserName;
    /** Email address (used for sending notifications).  */
    string mEmailAddress;
    /** Password hash.  */
    string mPassword;
    /** Password salt (overwritten by server).  */
    string mSalt;
  };
  /** Data type for holding a list of User fields structures. */
  sequence<UserFields> UserFieldsList;

  /**
   * UserGroupMembership fields structure.
   */
  struct UserGroupMembershipFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    long mUser;
    /**  */
    long mGroup;
  };
  /** Data type for holding a list of UserGroupMembership fields structures. */
  sequence<UserGroupMembershipFields> UserGroupMembershipFieldsList;

  /**
   * NotificationCategory fields structure.
   */
  struct NotificationCategoryFields {
    /** Unique identifier (for internal use only). */
    long id;
    /** Notification group name.  */
    string mName;
    /** Notification group description.  */
    string mDescription;
    /** Enable flag.  */
    bool mEnabled;
  };
  /** Data type for holding a list of NotificationCategory fields structures. */
  sequence<NotificationCategoryFields> NotificationCategoryFieldsList;

  /**
   * NotificationMembership fields structure.
   */
  struct NotificationMembershipFields {
    /** Unique identifier (for internal use only). */
    long id;
    /** User signed up for the notification category.  */
    long mUser;
    /** Notification category.  */
    long mCategory;
    /** Enable flag.  */
    bool mEnabled;
  };
  /** Data type for holding a list of NotificationMembership fields structures. */
  sequence<NotificationMembershipFields> NotificationMembershipFieldsList;

  /**
   * StructureOwner fields structure.
   */
  struct StructureOwnerFields {
    /** Unique identifier (for internal use only). */
    long id;
    /** Short name.  */
    string mName;
  };
  /** Data type for holding a list of StructureOwner fields structures. */
  sequence<StructureOwnerFields> StructureOwnerFieldsList;

  /**
   * Structure fields structure.
   */
  struct StructureFields {
    /** Unique identifier (for internal use only). */
    long id;
    /** Short name.  */
    string mName;
    /** One-line description.  */
    string mDescription;
    /** Type of structure, e.g. suspension bridge.  */
    string mType;
    /** Unit of distance  */
    Unit mDistanceUnit;
    /** Unit of force  */
    Unit mForceUnit;
    /** Unit of weight  */
    Unit mWeightUnit;
    /** Structure owner.  */
    long mOwner;
    /** Date of completion of original construction.  */
    double mDateBuilt;
    /** Latitude of center of structure (WGS84).  */
    float mLatitude;
    /** Longitude of center of structure (WGS84).  */
    float mLongitude;
    /** Name of location.  */
    string mLocation;
    /** State DOT structure ID.   */
    string mStateStructID;
    /** Federal structure ID.  */
    string mFedStructID;
  };
  /** Data type for holding a list of Structure fields structures. */
  sequence<StructureFields> StructureFieldsList;

  /**
   * FEMDof fields structure.
   */
  struct FEMDofFields {
    /** Unique identifier (for internal use only). */
    long id;
    /** Structure  */
    long mStructure;
    /** Local DOF number.  */
    int mLocalId;
    /** Finite element node.  */
    long mNode;
    /** Direction of motion.  */
    Quantity mDirection;
  };
  /** Data type for holding a list of FEMDof fields structures. */
  sequence<FEMDofFields> FEMDofFieldsList;

  /**
   * FEMNodalMass fields structure.
   */
  struct FEMNodalMassFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    string mDescription;
    /**  */
    double mMass1;
    /**  */
    double mMass2;
    /**  */
    double mMass3;
    /**  */
    double mMass4;
    /**  */
    double mMass5;
    /**  */
    double mMass6;
    /**  */
    long mNode;
  };
  /** Data type for holding a list of FEMNodalMass fields structures. */
  sequence<FEMNodalMassFields> FEMNodalMassFieldsList;

  /**
   * FEMNLElasticStrainStress fields structure.
   */
  struct FEMNLElasticStrainStressFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    int mMaterialID;
    /**  */
    int mRecordNumber;
    /**  */
    double mStrain;
    /**  */
    double mStress;
  };
  /** Data type for holding a list of FEMNLElasticStrainStress fields structures. */
  sequence<FEMNLElasticStrainStressFields> FEMNLElasticStrainStressFieldsList;

  /**
   * FEMBoundary fields structure.
   */
  struct FEMBoundaryFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    long mNode;
    /**  */
    BoundaryType mOvalization;
    /**  */
    BoundaryType mPhi;
    /**  */
    BoundaryType mRx;
    /**  */
    BoundaryType mRy;
    /**  */
    BoundaryType mRz;
    /**  */
    BoundaryType mUx;
    /**  */
    BoundaryType mUy;
    /**  */
    BoundaryType mUz;
    /**  */
    string mWarping;
  };
  /** Data type for holding a list of FEMBoundary fields structures. */
  sequence<FEMBoundaryFields> FEMBoundaryFieldsList;

  /**
   * FEMSectionPipe fields structure.
   */
  struct FEMSectionPipeFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    double mDiameter;
    /**  */
    double mSC;
    /**  */
    long mSection;
    /**  */
    double mSSarea;
    /**  */
    double mTC;
    /**  */
    double mThickness;
    /**  */
    double mTorfac;
    /**  */
    double mTSarea;
  };
  /** Data type for holding a list of FEMSectionPipe fields structures. */
  sequence<FEMSectionPipeFields> FEMSectionPipeFieldsList;

  /**
   * FEMCoordSystem fields structure.
   */
  struct FEMCoordSystemFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    double mAX;
    /**  */
    double mAY;
    /**  */
    double mAZ;
    /**  */
    double mBBY;
    /**  */
    double mBX;
    /**  */
    double mBZ;
    /**  */
    string mDescription;
    /**  */
    short mMode;
    /**  */
    int mP1;
    /**  */
    int mP2;
    /**  */
    int mP3;
    /**  */
    string mType;
    /**  */
    double mXorigin;
    /**  */
    double mYorigin;
    /**  */
    double mZorigin;
    /**  */
    int mLocalID;
  };
  /** Data type for holding a list of FEMCoordSystem fields structures. */
  sequence<FEMCoordSystemFields> FEMCoordSystemFieldsList;

  /**
   * FEMNode fields structure.
   */
  struct FEMNodeFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    string mDescription;
    /**  */
    long mSystem;
    /**  */
    double mX;
    /**  */
    double mY;
    /**  */
    double mZ;
    /**  */
    int mLocalID;
  };
  /** Data type for holding a list of FEMNode fields structures. */
  sequence<FEMNodeFields> FEMNodeFieldsList;

  /**
   * FEMTruss fields structure.
   */
  struct FEMTrussFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    string mDescription;
    /**  */
    int mElementID;
    /**  */
    double mEpsin;
    /**  */
    double mGapwidth;
    /**  */
    long mGroup;
    /**  */
    long mMaterial;
    /**  */
    long mN1;
    /**  */
    long mN2;
    /**  */
    int mRecordNmb;
    /**  */
    string mSave;
    /**  */
    double mSectionArea;
    /**  */
    double mTBirth;
    /**  */
    double mTDeath;
  };
  /** Data type for holding a list of FEMTruss fields structures. */
  sequence<FEMTrussFields> FEMTrussFieldsList;

  /**
   * FEMTimeFunctionData fields structure.
   */
  struct FEMTimeFunctionDataFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    double mDataTime;
    /**  */
    short mGMRecordID;
    /**  */
    int mRecordNmb;
    /**  */
    int mTimeFunctionID;
    /**  */
    double mTimeValue;
  };
  /** Data type for holding a list of FEMTimeFunctionData fields structures. */
  sequence<FEMTimeFunctionDataFields> FEMTimeFunctionDataFieldsList;

  /**
   * FEMPlasticMlMaterials fields structure.
   */
  struct FEMPlasticMlMaterialsFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    double mALPHA;
    /**  */
    double mDensity;
    /**  */
    double mE;
    /**  */
    string mHardening;
    /**  */
    int mMaterialID;
    /**  */
    double mNU;
    /**  */
    double mTREF;
  };
  /** Data type for holding a list of FEMPlasticMlMaterials fields structures. */
  sequence<FEMPlasticMlMaterialsFields> FEMPlasticMlMaterialsFieldsList;

  /**
   * FEMPlateGroup fields structure.
   */
  struct FEMPlateGroupFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    string mDisplacement;
    /**  */
    long mGroup;
    /**  */
    string mIniStrain;
    /**  */
    int mMaterialID;
    /**  */
    string mResult;
  };
  /** Data type for holding a list of FEMPlateGroup fields structures. */
  sequence<FEMPlateGroupFields> FEMPlateGroupFieldsList;

  /**
   * FEMBeam fields structure.
   */
  struct FEMBeamFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    long mAuxNode;
    /**  */
    string mDescription;
    /**  */
    int mElementID;
    /**  */
    long mEndRelease;
    /**  */
    double mEpsin;
    /**  */
    long mGroup;
    /**  */
    double mIRigidEnd;
    /**  */
    double mJRigidEnd;
    /**  */
    long mMaterial;
    /**  */
    long mNode1;
    /**  */
    long mNode2;
    /**  */
    int mRecordNmb;
    /**  */
    string mSave;
    /**  */
    long mSection;
    /**  */
    int mSubdivision;
    /**  */
    double mTBirth;
    /**  */
    double mTDeath;
  };
  /** Data type for holding a list of FEMBeam fields structures. */
  sequence<FEMBeamFields> FEMBeamFieldsList;

  /**
   * FEMCurvMomentData fields structure.
   */
  struct FEMCurvMomentDataFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    double mCurvature;
    /**  */
    int mCurvMomentID;
    /**  */
    double mMoment;
    /**  */
    int mRecordNmb;
  };
  /** Data type for holding a list of FEMCurvMomentData fields structures. */
  sequence<FEMCurvMomentDataFields> FEMCurvMomentDataFieldsList;

  /**
   * FEMPropertysets fields structure.
   */
  struct FEMPropertysetsFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    double mC;
    /**  */
    string mDescription;
    /**  */
    double mK;
    /**  */
    double mM;
    /**  */
    int mNC;
    /**  */
    int mNK;
    /**  */
    int mNM;
    /**  */
    string mNonlinear;
    /**  */
    int mPropertysetID;
    /**  */
    double mS;
  };
  /** Data type for holding a list of FEMPropertysets fields structures. */
  sequence<FEMPropertysetsFields> FEMPropertysetsFieldsList;

  /**
   * FEMOrthotropicMaterial fields structure.
   */
  struct FEMOrthotropicMaterialFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    double mDensity;
    /**  */
    double mEA;
    /**  */
    double mEB;
    /**  */
    double mEC;
    /**  */
    double mGAB;
    /**  */
    double mGAC;
    /**  */
    double mGBC;
    /**  */
    long mMaterial;
    /**  */
    double mNUAB;
    /**  */
    double mNUAC;
    /**  */
    double mNUBC;
  };
  /** Data type for holding a list of FEMOrthotropicMaterial fields structures. */
  sequence<FEMOrthotropicMaterialFields> FEMOrthotropicMaterialFieldsList;

  /**
   * FEMAppliedLoads fields structure.
   */
  struct FEMAppliedLoadsFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    int mAppliedLoadNmb;
    /**  */
    double mArrivalTime;
    /**  */
    short mLoadID;
    /**  */
    string mLoadType;
    /**  */
    string mSiteType;
    /**  */
    int mTimeFunctionID;
  };
  /** Data type for holding a list of FEMAppliedLoads fields structures. */
  sequence<FEMAppliedLoadsFields> FEMAppliedLoadsFieldsList;

  /**
   * FEMThermoOrthData fields structure.
   */
  struct FEMThermoOrthDataFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    double mALPHAA;
    /**  */
    double mALPHAB;
    /**  */
    double mALPHAC;
    /**  */
    double mEA;
    /**  */
    double mEB;
    /**  */
    double mEC;
    /**  */
    double mGAB;
    /**  */
    double mGAC;
    /**  */
    double mGBC;
    /**  */
    int mMaterialID;
    /**  */
    double mNUAB;
    /**  */
    double mNUAC;
    /**  */
    double mNUBC;
    /**  */
    int mRecordNmb;
    /**  */
    double mTheta;
  };
  /** Data type for holding a list of FEMThermoOrthData fields structures. */
  sequence<FEMThermoOrthDataFields> FEMThermoOrthDataFieldsList;

  /**
   * FEMContactPairs fields structure.
   */
  struct FEMContactPairsFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    int mContactorSurf;
    /**  */
    int mContGroupID;
    /**  */
    int mContPair;
    /**  */
    double mFContactor;
    /**  */
    double mFriction;
    /**  */
    double mFTarget;
    /**  */
    double mHeatTransf;
    /**  */
    int mRecordNmb;
    /**  */
    int mTargetSurf;
    /**  */
    double mTBirth;
    /**  */
    double mTDeath;
  };
  /** Data type for holding a list of FEMContactPairs fields structures. */
  sequence<FEMContactPairsFields> FEMContactPairsFieldsList;

  /**
   * FEMGeneral fields structure.
   */
  struct FEMGeneralFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    string mDescription;
    /**  */
    int mElementID;
    /**  */
    long mGroup;
    /**  */
    int mMatrixSet;
    /**  */
    short mNodeAmount;
    /**  */
    int mRecordNmb;
    /**  */
    string mSave;
  };
  /** Data type for holding a list of FEMGeneral fields structures. */
  sequence<FEMGeneralFields> FEMGeneralFieldsList;

  /**
   * FEMBeamGroup fields structure.
   */
  struct FEMBeamGroupFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    string mDisplacement;
    /**  */
    long mGroup;
    /**  */
    string mIniStrain;
    /**  */
    int mMaterialID;
    /**  */
    string mMC;
    /**  */
    int mMCrigidity;
    /**  */
    double mREmultiplyer;
    /**  */
    string mResult;
    /**  */
    string mREtype;
    /**  */
    short mRINT;
    /**  */
    int mSectionID;
    /**  */
    short mSINT;
    /**  */
    short mTINT;
  };
  /** Data type for holding a list of FEMBeamGroup fields structures. */
  sequence<FEMBeamGroupFields> FEMBeamGroupFieldsList;

  /**
   * FEMSectionRect fields structure.
   */
  struct FEMSectionRectFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    double mHeight;
    /**  */
    string mIShear;
    /**  */
    double mSC;
    /**  */
    long mSection;
    /**  */
    double mSSarea;
    /**  */
    double mTC;
    /**  */
    double mTorfac;
    /**  */
    double mTSarea;
    /**  */
    double mWidth;
  };
  /** Data type for holding a list of FEMSectionRect fields structures. */
  sequence<FEMSectionRectFields> FEMSectionRectFieldsList;

  /**
   * FEMBeamLoad fields structure.
   */
  struct FEMBeamLoadFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    double mArrivalTime;
    /**  */
    short mDeformDepend;
    /**  */
    short mDirectFilter;
    /**  */
    int mElementID;
    /**  */
    short mFace;
    /**  */
    long mGroup;
    /**  */
    double mP1;
    /**  */
    double mP2;
    /**  */
    int mRecordNmb;
    /**  */
    int mTimeFunctionID;
  };
  /** Data type for holding a list of FEMBeamLoad fields structures. */
  sequence<FEMBeamLoadFields> FEMBeamLoadFieldsList;

  /**
   * FEMLoadMassProportional fields structure.
   */
  struct FEMLoadMassProportionalFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    double mAX;
    /**  */
    double mAY;
    /**  */
    double mAZ;
    /**  */
    short mLoadID;
    /**  */
    double mMagnitude;
    /**  */
    long mStructure;
  };
  /** Data type for holding a list of FEMLoadMassProportional fields structures. */
  sequence<FEMLoadMassProportionalFields> FEMLoadMassProportionalFieldsList;

  /**
   * FEMLink fields structure.
   */
  struct FEMLinkFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    string mDescription;
    /**  */
    string mDisplacement;
    /**  */
    long mMasterNode;
    /**  */
    int mRLID;
    /**  */
    long mSlaveNode;
  };
  /** Data type for holding a list of FEMLink fields structures. */
  sequence<FEMLinkFields> FEMLinkFieldsList;

  /**
   * FEMAxesNode fields structure.
   */
  struct FEMAxesNodeFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    int mAxNodeID;
    /**  */
    long mGroup;
    /**  */
    long mNode1;
    /**  */
    long mNode2;
    /**  */
    long mNode3;
    /**  */
    int mRecordNmb;
  };
  /** Data type for holding a list of FEMAxesNode fields structures. */
  sequence<FEMAxesNodeFields> FEMAxesNodeFieldsList;

  /**
   * FEMNMTimeMass fields structure.
   */
  struct FEMNMTimeMassFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    double mMass;
    /**  */
    int mPropertyID;
    /**  */
    int mRecordNmb;
    /**  */
    double mTimeValue;
  };
  /** Data type for holding a list of FEMNMTimeMass fields structures. */
  sequence<FEMNMTimeMassFields> FEMNMTimeMassFieldsList;

  /**
   * FEMAppliedDisplacement fields structure.
   */
  struct FEMAppliedDisplacementFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    double mArrivalTime;
    /**  */
    string mDescription;
    /**  */
    short mDirection;
    /**  */
    double mFactor;
    /**  */
    long mNode;
    /**  */
    int mRecordNmb;
    /**  */
    int mTimeFunctionID;
  };
  /** Data type for holding a list of FEMAppliedDisplacement fields structures. */
  sequence<FEMAppliedDisplacementFields> FEMAppliedDisplacementFieldsList;

  /**
   * FEMTimeFunctions fields structure.
   */
  struct FEMTimeFunctionsFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    string mDescription;
    /**  */
    int mTimeFunctionID;
  };
  /** Data type for holding a list of FEMTimeFunctions fields structures. */
  sequence<FEMTimeFunctionsFields> FEMTimeFunctionsFieldsList;

  /**
   * FEMForceStrainData fields structure.
   */
  struct FEMForceStrainDataFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    double mForce;
    /**  */
    int mForceAxID;
    /**  */
    int mRecordNmb;
    /**  */
    double mStrain;
  };
  /** Data type for holding a list of FEMForceStrainData fields structures. */
  sequence<FEMForceStrainDataFields> FEMForceStrainDataFieldsList;

  /**
   * FEMSkewDOF fields structure.
   */
  struct FEMSkewDOFFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    string mDescription;
    /**  */
    long mNode;
    /**  */
    int mSkewSystemID;
  };
  /** Data type for holding a list of FEMSkewDOF fields structures. */
  sequence<FEMSkewDOFFields> FEMSkewDOFFieldsList;

  /**
   * FEMSectionI fields structure.
   */
  struct FEMSectionIFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    double mHeight;
    /**  */
    double mSC;
    /**  */
    long mSection;
    /**  */
    double mSSarea;
    /**  */
    double mTC;
    /**  */
    double mThick1;
    /**  */
    double mThick2;
    /**  */
    double mThick3;
    /**  */
    double mTorfac;
    /**  */
    double mTSarea;
    /**  */
    double mWidth1;
    /**  */
    double mWidth2;
  };
  /** Data type for holding a list of FEMSectionI fields structures. */
  sequence<FEMSectionIFields> FEMSectionIFieldsList;

  /**
   * FEMPlasticBilinearMaterial fields structure.
   */
  struct FEMPlasticBilinearMaterialFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    double mAlpha;
    /**  */
    double mDensity;
    /**  */
    double mE;
    /**  */
    double mEPA;
    /**  */
    double mET;
    /**  */
    string mHardening;
    /**  */
    long mMaterial;
    /**  */
    double mNU;
    /**  */
    double mTRef;
    /**  */
    double mYield;
  };
  /** Data type for holding a list of FEMPlasticBilinearMaterial fields structures. */
  sequence<FEMPlasticBilinearMaterialFields> FEMPlasticBilinearMaterialFieldsList;

  /**
   * FEMMTForceData fields structure.
   */
  struct FEMMTForceDataFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    double mForce;
    /**  */
    int mMomentRID;
    /**  */
    int mRecordNmb;
    /**  */
    int mTwistMomentID;
  };
  /** Data type for holding a list of FEMMTForceData fields structures. */
  sequence<FEMMTForceDataFields> FEMMTForceDataFieldsList;

  /**
   * FEMShellPressure fields structure.
   */
  struct FEMShellPressureFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    double mArrivalTime;
    /**  */
    short mDeformDepend;
    /**  */
    string mDescription;
    /**  */
    short mDirectFilter;
    /**  */
    int mElementID;
    /**  */
    short mFace;
    /**  */
    long mGroup;
    /**  */
    int mNodaux;
    /**  */
    double mP1;
    /**  */
    double mP2;
    /**  */
    double mP3;
    /**  */
    double mP4;
    /**  */
    int mRecordNmb;
    /**  */
    int mTimeFunctionID;
  };
  /** Data type for holding a list of FEMShellPressure fields structures. */
  sequence<FEMShellPressureFields> FEMShellPressureFieldsList;

  /**
   * FEMMatrices fields structure.
   */
  struct FEMMatricesFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    string mDescription;
    /**  */
    int mLump;
    /**  */
    int mMatrixID;
    /**  */
    string mMatrixType;
    /**  */
    int mND;
    /**  */
    int mNS;
  };
  /** Data type for holding a list of FEMMatrices fields structures. */
  sequence<FEMMatricesFields> FEMMatricesFieldsList;

  /**
   * FEMDamping fields structure.
   */
  struct FEMDampingFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    double mALPHA;
    /**  */
    double mBETA;
    /**  */
    long mGroup;
  };
  /** Data type for holding a list of FEMDamping fields structures. */
  sequence<FEMDampingFields> FEMDampingFieldsList;

  /**
   * FEMMaterial fields structure.
   */
  struct FEMMaterialFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    string mDescription;
    /**  */
    MaterialType mMaterialType;
    /**  */
    int mLocalID;
    /**  */
    long mStructure;
  };
  /** Data type for holding a list of FEMMaterial fields structures. */
  sequence<FEMMaterialFields> FEMMaterialFieldsList;

  /**
   * FEMMatrixData fields structure.
   */
  struct FEMMatrixDataFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    double mCoeff;
    /**  */
    int mColumnIndex;
    /**  */
    int mMatrixID;
    /**  */
    int mRecordNmb;
    /**  */
    int mRowIndex;
  };
  /** Data type for holding a list of FEMMatrixData fields structures. */
  sequence<FEMMatrixDataFields> FEMMatrixDataFieldsList;

  /**
   * FEMShellAxesOrtho fields structure.
   */
  struct FEMShellAxesOrthoFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    double mALFA;
    /**  */
    int mAxOrthoID;
    /**  */
    long mGroup;
    /**  */
    int mLineID;
    /**  */
    int mRecordNmb;
  };
  /** Data type for holding a list of FEMShellAxesOrtho fields structures. */
  sequence<FEMShellAxesOrthoFields> FEMShellAxesOrthoFieldsList;

  /**
   * FEMEndRelease fields structure.
   */
  struct FEMEndReleaseFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    string mDescription;
    /**  */
    short mMoment1;
    /**  */
    short mMoment2;
    /**  */
    short mMoment3;
    /**  */
    short mMoment4;
    /**  */
    short mMoment5;
    /**  */
    short mMoment6;
    /**  */
    int mLocalID;
  };
  /** Data type for holding a list of FEMEndRelease fields structures. */
  sequence<FEMEndReleaseFields> FEMEndReleaseFieldsList;

  /**
   * FEMTrussGroup fields structure.
   */
  struct FEMTrussGroupFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    string mDisplacement;
    /**  */
    string mGAPS;
    /**  */
    long mGroup;
    /**  */
    string mIniStrain;
    /**  */
    long mMaterial;
    /**  */
    double mSectionArea;
  };
  /** Data type for holding a list of FEMTrussGroup fields structures. */
  sequence<FEMTrussGroupFields> FEMTrussGroupFieldsList;

  /**
   * FEMInitialTemperature fields structure.
   */
  struct FEMInitialTemperatureFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    long mNode;
    /**  */
    double mTemperature;
  };
  /** Data type for holding a list of FEMInitialTemperature fields structures. */
  sequence<FEMInitialTemperatureFields> FEMInitialTemperatureFieldsList;

  /**
   * FEMThermoIsoMaterials fields structure.
   */
  struct FEMThermoIsoMaterialsFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    double mDensity;
    /**  */
    int mMaterialID;
    /**  */
    double mTREF;
  };
  /** Data type for holding a list of FEMThermoIsoMaterials fields structures. */
  sequence<FEMThermoIsoMaterialsFields> FEMThermoIsoMaterialsFieldsList;

  /**
   * FEMThermoIsoData fields structure.
   */
  struct FEMThermoIsoDataFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    double mALPHA;
    /**  */
    double mE;
    /**  */
    int mMaterialID;
    /**  */
    double mNU;
    /**  */
    int mRecordNmb;
    /**  */
    double mTheta;
  };
  /** Data type for holding a list of FEMThermoIsoData fields structures. */
  sequence<FEMThermoIsoDataFields> FEMThermoIsoDataFieldsList;

  /**
   * FEMContactGroup3 fields structure.
   */
  struct FEMContactGroup3Fields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    int mContGroupID;
    /**  */
    double mDepth;
    /**  */
    string mDescription;
    /**  */
    string mForces;
    /**  */
    double mFriction;
    /**  */
    string mIniPenetration;
    /**  */
    string mNodeToNode;
    /**  */
    double mOffset;
    /**  */
    string mPenetrAlgorithm;
    /**  */
    double mTBirth;
    /**  */
    double mTDeath;
    /**  */
    string mTied;
    /**  */
    double mTiedOffset;
    /**  */
    double mTolerance;
    /**  */
    string mTractions;
  };
  /** Data type for holding a list of FEMContactGroup3 fields structures. */
  sequence<FEMContactGroup3Fields> FEMContactGroup3FieldsList;

  /**
   * FEMNLElasticMaterials fields structure.
   */
  struct FEMNLElasticMaterialsFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    int mDcurve;
    /**  */
    double mDensity;
    /**  */
    int mMaterialID;
  };
  /** Data type for holding a list of FEMNLElasticMaterials fields structures. */
  sequence<FEMNLElasticMaterialsFields> FEMNLElasticMaterialsFieldsList;

  /**
   * FEMPlate fields structure.
   */
  struct FEMPlateFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    string mDescription;
    /**  */
    int mElementID;
    /**  */
    double mFlex11;
    /**  */
    double mFlex12;
    /**  */
    double mFlex22;
    /**  */
    long mGroup;
    /**  */
    int mMaterialID;
    /**  */
    double mMeps11;
    /**  */
    double mMeps12;
    /**  */
    double mMeps22;
    /**  */
    long mN1;
    /**  */
    long mN2;
    /**  */
    long mN3;
    /**  */
    int mRecordNmb;
    /**  */
    string mSave;
    /**  */
    double mTBirth;
    /**  */
    double mTDeath;
    /**  */
    double mThick;
  };
  /** Data type for holding a list of FEMPlate fields structures. */
  sequence<FEMPlateFields> FEMPlateFieldsList;

  /**
   * FEMIsoBeam fields structure.
   */
  struct FEMIsoBeamFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    long mAUX;
    /**  */
    string mDescription;
    /**  */
    int mElementID;
    /**  */
    double mEpaxl;
    /**  */
    double mEphoop;
    /**  */
    long mGroup;
    /**  */
    int mMaterialID;
    /**  */
    long mN1;
    /**  */
    long mN2;
    /**  */
    long mN3;
    /**  */
    long mN4;
    /**  */
    short mNodeAmount;
    /**  */
    int mRecordNmb;
    /**  */
    string mSave;
    /**  */
    int mSectionID;
    /**  */
    double mTBirth;
    /**  */
    double mTDeath;
  };
  /** Data type for holding a list of FEMIsoBeam fields structures. */
  sequence<FEMIsoBeamFields> FEMIsoBeamFieldsList;

  /**
   * FEMAppliedConcentratedLoad fields structure.
   */
  struct FEMAppliedConcentratedLoadFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    double mArrivalTime;
    /**  */
    string mDescription;
    /**  */
    short mDirection;
    /**  */
    double mFactor;
    /**  */
    long mNodeAux;
    /**  */
    long mNodeID;
    /**  */
    int mRecordNmb;
    /**  */
    int mTimeFunctionID;
  };
  /** Data type for holding a list of FEMAppliedConcentratedLoad fields structures. */
  sequence<FEMAppliedConcentratedLoadFields> FEMAppliedConcentratedLoadFieldsList;

  /**
   * FEMTwoDSolidGroup fields structure.
   */
  struct FEMTwoDSolidGroupFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    long mAuxNode;
    /**  */
    string mDisplacement;
    /**  */
    long mGroup;
    /**  */
    int mMaterialID;
    /**  */
    string mResult;
    /**  */
    string mSubtype;
  };
  /** Data type for holding a list of FEMTwoDSolidGroup fields structures. */
  sequence<FEMTwoDSolidGroupFields> FEMTwoDSolidGroupFieldsList;

  /**
   * FEMGroup fields structure.
   */
  struct FEMGroupFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    string mDescription;
    /**  */
    GroupType mGroupType;
    /**  */
    int mLocalID;
    /**  */
    long mStructure;
  };
  /** Data type for holding a list of FEMGroup fields structures. */
  sequence<FEMGroupFields> FEMGroupFieldsList;

  /**
   * FEMProperties fields structure.
   */
  struct FEMPropertiesFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    string mDescription;
    /**  */
    int mPropertyID;
    /**  */
    string mPropertyType;
    /**  */
    string mRupture;
    /**  */
    double mXC;
    /**  */
    double mXN;
  };
  /** Data type for holding a list of FEMProperties fields structures. */
  sequence<FEMPropertiesFields> FEMPropertiesFieldsList;

  /**
   * FEMThreeDSolidGroup fields structure.
   */
  struct FEMThreeDSolidGroupFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    string mDisplacement;
    /**  */
    long mGroup;
    /**  */
    int mMaterialID;
    /**  */
    string mResult;
  };
  /** Data type for holding a list of FEMThreeDSolidGroup fields structures. */
  sequence<FEMThreeDSolidGroupFields> FEMThreeDSolidGroupFieldsList;

  /**
   * FEMThreeDSolid fields structure.
   */
  struct FEMThreeDSolidFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    string mDescription;
    /**  */
    int mElementID;
    /**  */
    long mGroup;
    /**  */
    int mMaterialID;
    /**  */
    int mMaxes;
    /**  */
    long mN1;
    /**  */
    long mN10;
    /**  */
    long mN11;
    /**  */
    long mN12;
    /**  */
    long mN13;
    /**  */
    long mN14;
    /**  */
    long mN15;
    /**  */
    long mN16;
    /**  */
    long mN17;
    /**  */
    long mN18;
    /**  */
    long mN19;
    /**  */
    long mN2;
    /**  */
    long mN20;
    /**  */
    long mN21;
    /**  */
    long mN22;
    /**  */
    long mN23;
    /**  */
    long mN24;
    /**  */
    long mN25;
    /**  */
    long mN26;
    /**  */
    long mN27;
    /**  */
    long mN3;
    /**  */
    long mN4;
    /**  */
    long mN5;
    /**  */
    long mN6;
    /**  */
    long mN7;
    /**  */
    long mN8;
    /**  */
    long mN9;
    /**  */
    short mNodeAmount;
    /**  */
    int mRecordNmb;
    /**  */
    string mSave;
    /**  */
    double mTBirth;
    /**  */
    double mTDeath;
  };
  /** Data type for holding a list of FEMThreeDSolid fields structures. */
  sequence<FEMThreeDSolidFields> FEMThreeDSolidFieldsList;

  /**
   * FEMSectionProp fields structure.
   */
  struct FEMSectionPropFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    double mArea;
    /**  */
    double mRinertia;
    /**  */
    double mSarea;
    /**  */
    long mSection;
    /**  */
    double mSinertia;
    /**  */
    double mTarea;
    /**  */
    double mTinertia;
  };
  /** Data type for holding a list of FEMSectionProp fields structures. */
  sequence<FEMSectionPropFields> FEMSectionPropFieldsList;

  /**
   * FEMElasticMaterial fields structure.
   */
  struct FEMElasticMaterialFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    double mAlpha;
    /**  */
    double mDensity;
    /**  */
    double mE;
    /**  */
    long mMaterial;
    /**  */
    double mNU;
  };
  /** Data type for holding a list of FEMElasticMaterial fields structures. */
  sequence<FEMElasticMaterialFields> FEMElasticMaterialFieldsList;

  /**
   * FEMPoints fields structure.
   */
  struct FEMPointsFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    string mDescription;
    /**  */
    int mPointID;
    /**  */
    int mSystemID;
    /**  */
    double mX;
    /**  */
    double mY;
    /**  */
    double mZ;
  };
  /** Data type for holding a list of FEMPoints fields structures. */
  sequence<FEMPointsFields> FEMPointsFieldsList;

  /**
   * FEMThermoOrthMaterials fields structure.
   */
  struct FEMThermoOrthMaterialsFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    double mDensity;
    /**  */
    int mMaterialID;
    /**  */
    double mTREF;
  };
  /** Data type for holding a list of FEMThermoOrthMaterials fields structures. */
  sequence<FEMThermoOrthMaterialsFields> FEMThermoOrthMaterialsFieldsList;

  /**
   * FEMConstraints fields structure.
   */
  struct FEMConstraintsFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    int mConstraintID;
    /**  */
    string mDescription;
    /**  */
    string mSlaveDOF;
    /**  */
    int mSlaveNode;
  };
  /** Data type for holding a list of FEMConstraints fields structures. */
  sequence<FEMConstraintsFields> FEMConstraintsFieldsList;

  /**
   * FEMMCrigidities fields structure.
   */
  struct FEMMCrigiditiesFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    string mAcurveType;
    /**  */
    int mAlpha;
    /**  */
    double mAxialCF;
    /**  */
    string mBcurveType;
    /**  */
    double mBendingCF;
    /**  */
    int mBeta;
    /**  */
    double mDensity;
    /**  */
    int mForceAxID;
    /**  */
    string mHardening;
    /**  */
    double mMassArea;
    /**  */
    double mMassR;
    /**  */
    double mMassS;
    /**  */
    double mMassT;
    /**  */
    int mMomentRID;
    /**  */
    int mMomentSID;
    /**  */
    int mMomentTID;
    /**  */
    int mRigidityID;
    /**  */
    string mTcurveType;
    /**  */
    double mTorsionCF;
  };
  /** Data type for holding a list of FEMMCrigidities fields structures. */
  sequence<FEMMCrigiditiesFields> FEMMCrigiditiesFieldsList;

  /**
   * FEMSkeySysNode fields structure.
   */
  struct FEMSkeySysNodeFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    string mDescription;
    /**  */
    long mNode1;
    /**  */
    long mNode2;
    /**  */
    long mNode3;
    /**  */
    int mSkewSystemID;
  };
  /** Data type for holding a list of FEMSkeySysNode fields structures. */
  sequence<FEMSkeySysNodeFields> FEMSkeySysNodeFieldsList;

  /**
   * FEMIsoBeamGroup fields structure.
   */
  struct FEMIsoBeamGroupFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    string mDisplacement;
    /**  */
    long mGroup;
    /**  */
    string mIniStrain;
    /**  */
    int mMaterialID;
    /**  */
    string mResult;
    /**  */
    int mSectionID;
  };
  /** Data type for holding a list of FEMIsoBeamGroup fields structures. */
  sequence<FEMIsoBeamGroupFields> FEMIsoBeamGroupFieldsList;

  /**
   * FEMShellDOF fields structure.
   */
  struct FEMShellDOFFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    string mDOFnumber;
    /**  */
    long mNode;
    /**  */
    int mVectorID;
  };
  /** Data type for holding a list of FEMShellDOF fields structures. */
  sequence<FEMShellDOFFields> FEMShellDOFFieldsList;

  /**
   * FEMCrossSection fields structure.
   */
  struct FEMCrossSectionFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    string mDescription;
    /**  */
    SectionType mSectionType;
    /**  */
    int mLocalID;
    /**  */
    long mStructure;
  };
  /** Data type for holding a list of FEMCrossSection fields structures. */
  sequence<FEMCrossSectionFields> FEMCrossSectionFieldsList;

  /**
   * FEMTwistMomentData fields structure.
   */
  struct FEMTwistMomentDataFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    double mMoment;
    /**  */
    int mRecordNmb;
    /**  */
    double mTwist;
    /**  */
    int mTwistMomentID;
  };
  /** Data type for holding a list of FEMTwistMomentData fields structures. */
  sequence<FEMTwistMomentDataFields> FEMTwistMomentDataFieldsList;

  /**
   * FEMShell fields structure.
   */
  struct FEMShellFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    string mDescription;
    /**  */
    int mElementID;
    /**  */
    long mGroup;
    /**  */
    long mMaterial;
    /**  */
    long mN1;
    /**  */
    long mN2;
    /**  */
    long mN3;
    /**  */
    long mN4;
    /**  */
    long mN5;
    /**  */
    long mN6;
    /**  */
    long mN7;
    /**  */
    long mN8;
    /**  */
    long mN9;
    /**  */
    short mNodeAmount;
    /**  */
    int mRecordNmb;
    /**  */
    string mSave;
    /**  */
    double mT1;
    /**  */
    double mT2;
    /**  */
    double mT3;
    /**  */
    double mT4;
    /**  */
    double mT5;
    /**  */
    double mT6;
    /**  */
    double mT7;
    /**  */
    double mT8;
    /**  */
    double mT9;
    /**  */
    double mTBirth;
    /**  */
    double mTDeath;
  };
  /** Data type for holding a list of FEMShell fields structures. */
  sequence<FEMShellFields> FEMShellFieldsList;

  /**
   * FEMNTNContact fields structure.
   */
  struct FEMNTNContactFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    int mContactorNode;
    /**  */
    int mContGroupID;
    /**  */
    int mContPair;
    /**  */
    string mPrintRes;
    /**  */
    int mRecordNmb;
    /**  */
    string mSaveRes;
    /**  */
    int mTargetNode;
    /**  */
    double mTargetNx;
    /**  */
    double mTargetNy;
    /**  */
    double mTargetNz;
  };
  /** Data type for holding a list of FEMNTNContact fields structures. */
  sequence<FEMNTNContactFields> FEMNTNContactFieldsList;

  /**
   * FEMShellLayer fields structure.
   */
  struct FEMShellLayerFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    long mGroup;
    /**  */
    int mLayerNumber;
    /**  */
    int mMaterialID;
    /**  */
    double mPThick;
    /**  */
    int mRecordNmb;
  };
  /** Data type for holding a list of FEMShellLayer fields structures. */
  sequence<FEMShellLayerFields> FEMShellLayerFieldsList;

  /**
   * FEMSkewSysAngles fields structure.
   */
  struct FEMSkewSysAnglesFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    string mDescription;
    /**  */
    double mPHI;
    /**  */
    int mSkewSystemID;
    /**  */
    double mTHETA;
    /**  */
    double mXSI;
  };
  /** Data type for holding a list of FEMSkewSysAngles fields structures. */
  sequence<FEMSkewSysAnglesFields> FEMSkewSysAnglesFieldsList;

  /**
   * FEMGroundMotionRecord fields structure.
   */
  struct FEMGroundMotionRecordFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    string mDescription;
    /**  */
    short mGMRecordID;
    /**  */
    string mGMRecordName;
  };
  /** Data type for holding a list of FEMGroundMotionRecord fields structures. */
  sequence<FEMGroundMotionRecordFields> FEMGroundMotionRecordFieldsList;

  /**
   * FEMGeneralGroup fields structure.
   */
  struct FEMGeneralGroupFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    long mGroup;
    /**  */
    int mMatrixSet;
    /**  */
    string mResult;
    /**  */
    string mSkewSystem;
  };
  /** Data type for holding a list of FEMGeneralGroup fields structures. */
  sequence<FEMGeneralGroupFields> FEMGeneralGroupFieldsList;

  /**
   * FEMTwoDSolid fields structure.
   */
  struct FEMTwoDSolidFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    double mBet;
    /**  */
    string mDescription;
    /**  */
    int mElementID;
    /**  */
    long mGroup;
    /**  */
    int mMaterialID;
    /**  */
    long mN1;
    /**  */
    long mN2;
    /**  */
    long mN3;
    /**  */
    long mN4;
    /**  */
    long mN5;
    /**  */
    long mN6;
    /**  */
    long mN7;
    /**  */
    long mN8;
    /**  */
    long mN9;
    /**  */
    short mNodeAmount;
    /**  */
    int mRecordNmb;
    /**  */
    string mSave;
    /**  */
    double mTBirth;
    /**  */
    double mTDeath;
    /**  */
    double mThick;
  };
  /** Data type for holding a list of FEMTwoDSolid fields structures. */
  sequence<FEMTwoDSolidFields> FEMTwoDSolidFieldsList;

  /**
   * FEMAppliedTemperature fields structure.
   */
  struct FEMAppliedTemperatureFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    double mArrivalTime;
    /**  */
    double mFactor;
    /**  */
    long mNode;
    /**  */
    int mRecordNmbr;
    /**  */
    int mTimeFunctionID;
  };
  /** Data type for holding a list of FEMAppliedTemperature fields structures. */
  sequence<FEMAppliedTemperatureFields> FEMAppliedTemperatureFieldsList;

  /**
   * FEMMatrixSets fields structure.
   */
  struct FEMMatrixSetsFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    int mDamping;
    /**  */
    string mDescription;
    /**  */
    int mMass;
    /**  */
    int mMatrixSetID;
    /**  */
    int mStiffness;
    /**  */
    int mStress;
  };
  /** Data type for holding a list of FEMMatrixSets fields structures. */
  sequence<FEMMatrixSetsFields> FEMMatrixSetsFieldsList;

  /**
   * FEMConstraintCoef fields structure.
   */
  struct FEMConstraintCoefFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    double mCoefficient;
    /**  */
    int mConstraintID;
    /**  */
    string mDescription;
    /**  */
    string mMasterDOF;
    /**  */
    int mMasterNode;
    /**  */
    int mRecordNmb;
  };
  /** Data type for holding a list of FEMConstraintCoef fields structures. */
  sequence<FEMConstraintCoefFields> FEMConstraintCoefFieldsList;

  /**
   * FEMSectionBox fields structure.
   */
  struct FEMSectionBoxFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    double mHeight;
    /**  */
    double mSC;
    /**  */
    long mSection;
    /**  */
    double mSSarea;
    /**  */
    double mTC;
    /**  */
    double mThick1;
    /**  */
    double mThick2;
    /**  */
    double mTorfac;
    /**  */
    double mTSarea;
    /**  */
    double mWidth;
  };
  /** Data type for holding a list of FEMSectionBox fields structures. */
  sequence<FEMSectionBoxFields> FEMSectionBoxFieldsList;

  /**
   * FEMNKDisplForce fields structure.
   */
  struct FEMNKDisplForceFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    double mDisplacement;
    /**  */
    double mForce;
    /**  */
    int mPropertyID;
    /**  */
    int mRecordNmb;
  };
  /** Data type for holding a list of FEMNKDisplForce fields structures. */
  sequence<FEMNKDisplForceFields> FEMNKDisplForceFieldsList;

  /**
   * FEMPlasticStrainStress fields structure.
   */
  struct FEMPlasticStrainStressFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    int mMaterialID;
    /**  */
    int mRecordNumber;
    /**  */
    double mStrain;
    /**  */
    double mStress;
  };
  /** Data type for holding a list of FEMPlasticStrainStress fields structures. */
  sequence<FEMPlasticStrainStressFields> FEMPlasticStrainStressFieldsList;

  /**
   * FEMShellAxesOrthoData fields structure.
   */
  struct FEMShellAxesOrthoDataFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    int mAxOrthoID;
    /**  */
    int mElementID;
    /**  */
    int mRecordNmb;
  };
  /** Data type for holding a list of FEMShellAxesOrthoData fields structures. */
  sequence<FEMShellAxesOrthoDataFields> FEMShellAxesOrthoDataFieldsList;

  /**
   * FEMGeneralNode fields structure.
   */
  struct FEMGeneralNodeFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    int mElementID;
    /**  */
    long mGroup;
    /**  */
    short mLocalNmb;
    /**  */
    long mNode;
    /**  */
    int mRecordNmb;
  };
  /** Data type for holding a list of FEMGeneralNode fields structures. */
  sequence<FEMGeneralNodeFields> FEMGeneralNodeFieldsList;

  /**
   * FEMStrLines fields structure.
   */
  struct FEMStrLinesFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    int mLineID;
    /**  */
    int mP1;
    /**  */
    int mP2;
  };
  /** Data type for holding a list of FEMStrLines fields structures. */
  sequence<FEMStrLinesFields> FEMStrLinesFieldsList;

  /**
   * FEMContactSurface fields structure.
   */
  struct FEMContactSurfaceFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    int mContGroupID;
    /**  */
    int mContSegment;
    /**  */
    int mContSurface;
    /**  */
    long mN1;
    /**  */
    long mN2;
    /**  */
    long mN3;
    /**  */
    long mN4;
    /**  */
    int mRecordNmb;
  };
  /** Data type for holding a list of FEMContactSurface fields structures. */
  sequence<FEMContactSurfaceFields> FEMContactSurfaceFieldsList;

  /**
   * FEMMCForceData fields structure.
   */
  struct FEMMCForceDataFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    int mCurvMomentID;
    /**  */
    double mForce;
    /**  */
    int mMomentSTID;
    /**  */
    int mRecordNmb;
  };
  /** Data type for holding a list of FEMMCForceData fields structures. */
  sequence<FEMMCForceDataFields> FEMMCForceDataFieldsList;

  /**
   * FEMSpring fields structure.
   */
  struct FEMSpringFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    double mAX;
    /**  */
    double mAY;
    /**  */
    double mAZ;
    /**  */
    string mDescription;
    /**  */
    int mElementID;
    /**  */
    long mGroup;
    /**  */
    short mID1;
    /**  */
    short mID2;
    /**  */
    long mN1;
    /**  */
    long mN2;
    /**  */
    int mPropertySet;
    /**  */
    int mRecordNmb;
    /**  */
    string mSave;
    /**  */
    double mTBirth;
    /**  */
    double mTDeath;
  };
  /** Data type for holding a list of FEMSpring fields structures. */
  sequence<FEMSpringFields> FEMSpringFieldsList;

  /**
   * FEMSpringGroup fields structure.
   */
  struct FEMSpringGroupFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    string mBolt;
    /**  */
    long mGroup;
    /**  */
    string mNonlinear;
    /**  */
    int mPropertySet;
    /**  */
    string mResult;
    /**  */
    string mSkewSystem;
  };
  /** Data type for holding a list of FEMSpringGroup fields structures. */
  sequence<FEMSpringGroupFields> FEMSpringGroupFieldsList;

  /**
   * FEMShellGroup fields structure.
   */
  struct FEMShellGroupFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    string mDisplacement;
    /**  */
    long mGroup;
    /**  */
    long mMaterial;
    /**  */
    int mNLayers;
    /**  */
    string mResult;
    /**  */
    short mSectionResult;
    /**  */
    string mStressReference;
    /**  */
    double mThickness;
  };
  /** Data type for holding a list of FEMShellGroup fields structures. */
  sequence<FEMShellGroupFields> FEMShellGroupFieldsList;

  /**
   * DaqUnit fields structure.
   */
  struct DaqUnitFields {
    /** Unique identifier (for internal use only). */
    long id;
    /** * Model name of DAQ unit (e.g. 'Narada').
    */
    string mModel;
    /** * Unique identifier of DAQ unit (e.g. serial number, or unit ID).
    */
    string mIdentifier;
  };
  /** Data type for holding a list of DaqUnit fields structures. */
  sequence<DaqUnitFields> DaqUnitFieldsList;

  /**
   * DaqUnitChannel fields structure.
   */
  struct DaqUnitChannelFields {
    /** Unique identifier (for internal use only). */
    long id;
    /** * Corresponding data acquisition unit.
    */
    long mUnit;
    /** * Local channel number.
    */
    short mNumber;
  };
  /** Data type for holding a list of DaqUnitChannel fields structures. */
  sequence<DaqUnitChannelFields> DaqUnitChannelFieldsList;

  /**
   * Sensor fields structure.
   */
  struct SensorFields {
    /** Unique identifier (for internal use only). */
    long id;
    /** * Sensor type.
    */
    SensorType mType;
    /** * Sensor model (e.g. Crossbow XYZ).
    */
    string mModel;
    /** * Unique identifier (e.g. serial number).
    */
    string mIdentifier;
    /** * Description (to help identify the sensor).
    */
    string mDescription;
  };
  /** Data type for holding a list of Sensor fields structures. */
  sequence<SensorFields> SensorFieldsList;

  /**
   * SensorChannel fields structure.
   */
  struct SensorChannelFields {
    /** Unique identifier (for internal use only). */
    long id;
    /** * Corresponding sensor.
    */
    long mSensor;
    /** * Local channel number.
    */
    short mNumber;
    /** * Description (to help identify the sensor channel).
    */
    string mDescription;
  };
  /** Data type for holding a list of SensorChannel fields structures. */
  sequence<SensorChannelFields> SensorChannelFieldsList;

  /**
   * SensorChannelConnection fields structure.
   */
  struct SensorChannelConnectionFields {
    /** Unique identifier (for internal use only). */
    long id;
    /** * Connected sensor channel.
    */
    long mSensorChannel;
    /** * Connected DAQ unit channel.
    */
    long mDaqUnitChannel;
    /** * Location of the sensor for the duration of this connection.
    */
    long mLocation;
    /** * Associated component of the sensor for the duration of this connection.
    */
    long mComponent;
    /** * Node defining orientation of the sensor.
   *
   * The orientation is defined as (OrientNode - Location).  The node
   * can be left undefined if the sensor has no orientation.
    */
    long mOrientNode;
    /** * Time and date when this connection was made.
    */
    double mCreated;
    /** * Time and date when the connection was severed.
   *
   * Use a large value (e.g. > 1.0e10) to indicate that the connection
   * is still active.
    */
    double mSevered;
    /** * Notification category.
   *
   * See UpdateIntervalMax for details.
    */
    long mNotificationCategory;
    /** * Required update interval in seconds.
   *
   * If this connection is active and the sensor data is not updated within
   * this interval, the monitoring task will send out notifications to
   * subscribed users for the configured NotificationCategory.
   *
   * If this value is 0.0 or less, the monitoring task will not check this
   * connection.
    */
    float mUpdateIntervalMax;
    /** * Data conversion coefficient C0.
    */
    float mC0;
    /** * Data conversion coefficient C1.
    */
    float mC1;
  };
  /** Data type for holding a list of SensorChannelConnection fields structures. */
  sequence<SensorChannelConnectionFields> SensorChannelConnectionFieldsList;

  /**
   * FixedCamera fields structure.
   */
  struct FixedCameraFields {
    /** Unique identifier (for internal use only). */
    long id;
    /** Location of camera.  */
    long mNode;
    /** Description, to help identify the camera.  */
    string mDescription;
  };
  /** Data type for holding a list of FixedCamera fields structures. */
  sequence<FixedCameraFields> FixedCameraFieldsList;

  /**
   * BridgeDetails fields structure.
   */
  struct BridgeDetailsFields {
    /** Unique identifier (for internal use only). */
    long id;
    /** Corresponding bridge structure.  */
    long mStructure;
    /** Date of completion of most recent rehabilitation.  */
    double mLastMajorRehab;
    /** Number of ramps attached.  */
    int mRampsAttached;
    /** Principal construction material of main span.  */
    Material mMainspanMaterial;
    /** Length of the longest span (in configured distance unit for this structure).  */
    float mLongestSpanLength;
    /** Length of the longest span (in configured distance unit for this structure).  */
    float mBridgeLength;
    /** Length of the longest span (in configured distance unit for this structure).  */
    float mOutToOutWidth;
    /** Area of bridge deck (using configured distance unit for this structure).  */
    float mBridgeDeckArea;
    /** Width of median (in configured distance unit for this structure).  */
    float mMedianWidth;
    /** Type of abutment.  */
    float mAbutmentType;
    /** Height of abutment (in configured distance unit for this structure).  */
    float mAbutmentHeight;
    /** Bridge coordinate system.  */
    long mBridgeCoordSystem;
    /** Inspection frequency [days].  */
    int mInspFreq;
    /** Scour evaluation.  */
    bool mScourEvl;
    /** Number of pins.  */
    int mNumPins;
    /** Super structure design type.  */
    SuperStructureDesignType mSuperStructureDesignType;
    /** Salt usage level.  */
    SaltUsageLevel mSaltUsageLevel;
    /** Snow accumulation.  */
    SnowAccumulation mSnowAccumulation;
    /** Climate group.  */
    ClimateGroup mClimateGroup;
    /** Functional class.  */
    FunctionalClass mFuncClass;
    /** Inspection key.  */
    string mInspKey;
    /** Element design type.  */
    string mElementDesignType;
  };
  /** Data type for holding a list of BridgeDetails fields structures. */
  sequence<BridgeDetailsFields> BridgeDetailsFieldsList;

  /**
   * FacilityRoad fields structure.
   */
  struct FacilityRoadFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    long mRoad;
    /**  */
    long mStructure;
  };
  /** Data type for holding a list of FacilityRoad fields structures. */
  sequence<FacilityRoadFields> FacilityRoadFieldsList;

  /**
   * FacilityRailway fields structure.
   */
  struct FacilityRailwayFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    long mRailway;
    /**  */
    long mStructure;
  };
  /** Data type for holding a list of FacilityRailway fields structures. */
  sequence<FacilityRailwayFields> FacilityRailwayFieldsList;

  /**
   * FeatureRoad fields structure.
   */
  struct FeatureRoadFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    long mRoad;
    /**  */
    long mStructure;
  };
  /** Data type for holding a list of FeatureRoad fields structures. */
  sequence<FeatureRoadFields> FeatureRoadFieldsList;

  /**
   * FeatureRailway fields structure.
   */
  struct FeatureRailwayFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    long mRailway;
    /**  */
    long mStructure;
  };
  /** Data type for holding a list of FeatureRailway fields structures. */
  sequence<FeatureRailwayFields> FeatureRailwayFieldsList;

  /**
   * FeatureRiver fields structure.
   */
  struct FeatureRiverFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    long mRiver;
    /**  */
    long mStructure;
  };
  /** Data type for holding a list of FeatureRiver fields structures. */
  sequence<FeatureRiverFields> FeatureRiverFieldsList;

  /**
   * Road fields structure.
   */
  struct RoadFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    string mName;
  };
  /** Data type for holding a list of Road fields structures. */
  sequence<RoadFields> RoadFieldsList;

  /**
   * Railway fields structure.
   */
  struct RailwayFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    string mName;
  };
  /** Data type for holding a list of Railway fields structures. */
  sequence<RailwayFields> RailwayFieldsList;

  /**
   * River fields structure.
   */
  struct RiverFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    string mName;
  };
  /** Data type for holding a list of River fields structures. */
  sequence<RiverFields> RiverFieldsList;

  /**
   * BridgeInspection fields structure.
   */
  struct BridgeInspectionFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    double mAssessmentDate;
    /**  */
    long mInspector;
    /**  */
    long mInspectionAgency;
  };
  /** Data type for holding a list of BridgeInspection fields structures. */
  sequence<BridgeInspectionFields> BridgeInspectionFieldsList;

  /**
   * Inspector fields structure.
   */
  struct InspectorFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    string mName;
  };
  /** Data type for holding a list of Inspector fields structures. */
  sequence<InspectorFields> InspectorFieldsList;

  /**
   * InspectionAgency fields structure.
   */
  struct InspectionAgencyFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    string mName;
  };
  /** Data type for holding a list of InspectionAgency fields structures. */
  sequence<InspectionAgencyFields> InspectionAgencyFieldsList;

  /**
   * StructureAssessment fields structure.
   */
  struct StructureAssessmentFields {
    /** Unique identifier (for internal use only). */
    long id;
    /** Corresponding structure.  */
    long mStructure;
    /**  */
    double mAssessmentDate;
    /**  */
    float mTotalReliability;
    /**  */
    float mTotalRisk;
    /**  */
    float mTotalRating;
    /**  */
    long mBridgeInspection;
  };
  /** Data type for holding a list of StructureAssessment fields structures. */
  sequence<StructureAssessmentFields> StructureAssessmentFieldsList;

  /**
   * StructureRetrofit fields structure.
   */
  struct StructureRetrofitFields {
    /** Unique identifier (for internal use only). */
    long id;
    /** Corresponding structure.  */
    long mStructure;
    /**  */
    double mDate;
    /**  */
    string mSummary;
  };
  /** Data type for holding a list of StructureRetrofit fields structures. */
  sequence<StructureRetrofitFields> StructureRetrofitFieldsList;

  /**
   * PontisElement fields structure.
   */
  struct PontisElementFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    string mDescription;
    /**  */
    int mCategory;
    /**  */
    Unit mUnits;
  };
  /** Data type for holding a list of PontisElement fields structures. */
  sequence<PontisElementFields> PontisElementFieldsList;

  /**
   * StructureComponent fields structure.
   */
  struct StructureComponentFields {
    /** Unique identifier (for internal use only). */
    long id;
    /** Corresponding structure.  */
    long mStructure;
    /**  */
    StructureComponentType mType;
    /**  */
    string mDescription;
    /**  */
    long mPontisElement;
    /**  */
    Material mMaterial;
  };
  /** Data type for holding a list of StructureComponent fields structures. */
  sequence<StructureComponentFields> StructureComponentFieldsList;

  /**
   * ComponentInspElement fields structure.
   */
  struct ComponentInspElementFields {
    /** Unique identifier (for internal use only). */
    long id;
    /** Corresponding component  */
    long mStructureComponent;
    /**  */
    InspElementType mType;
    /**  */
    string mDescription;
  };
  /** Data type for holding a list of ComponentInspElement fields structures. */
  sequence<ComponentInspElementFields> ComponentInspElementFieldsList;

  /**
   * StructureComponentGroups fields structure.
   */
  struct StructureComponentGroupsFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    long mComponent;
    /**  */
    long mFEMGroup;
  };
  /** Data type for holding a list of StructureComponentGroups fields structures. */
  sequence<StructureComponentGroupsFields> StructureComponentGroupsFieldsList;

  /**
   * StructureComponentReliability fields structure.
   */
  struct StructureComponentReliabilityFields {
    /** Unique identifier (for internal use only). */
    long id;
    /** Corresponding structure component.  */
    long mComponent;
    /** Date when computed.  */
    double mComputeDate;
    /**  */
    float mSensorMean;
    /**  */
    float mSensorCov;
    /**  */
    float mComputeDLMean;
    /**  */
    float mComputeDLCov;
    /**  */
    float mComputeLLMean;
    /**  */
    float mComputeLLCov;
    /**  */
    float mComputeTempMean;
    /**  */
    float mComputeTempCov;
  };
  /** Data type for holding a list of StructureComponentReliability fields structures. */
  sequence<StructureComponentReliabilityFields> StructureComponentReliabilityFieldsList;

  /**
   * StructureComponentAssessment fields structure.
   */
  struct StructureComponentAssessmentFields {
    /** Unique identifier (for internal use only). */
    long id;
    /** Corresponding structure component.  */
    long mComponent;
    /** Date of assessment.  */
    double mAssessmentDate;
    /**  */
    float mReliability;
    /**  */
    float mRisk;
    /**  */
    float mRating;
    /**  */
    long mBridgeInspection;
  };
  /** Data type for holding a list of StructureComponentAssessment fields structures. */
  sequence<StructureComponentAssessmentFields> StructureComponentAssessmentFieldsList;

  /**
   * StructureComponentRating fields structure.
   */
  struct StructureComponentRatingFields {
    /** Unique identifier (for internal use only). */
    long id;
    /** Corresponding structure component.  */
    long mComponent;
    /** Date of assessment.  */
    double mAssessmentDate;
    /** Ultimate acute limit state for component rating.  */
    float mUltimateLimit;
    /** Average target for component rating.  */
    float mAvgRatingLimit;
    /** Environment impact id for optimization goal.  */
    float mOptmObjective;
  };
  /** Data type for holding a list of StructureComponentRating fields structures. */
  sequence<StructureComponentRatingFields> StructureComponentRatingFieldsList;

  /**
   * StructureComponentRepairOption fields structure.
   */
  struct StructureComponentRepairOptionFields {
    /** Unique identifier (for internal use only). */
    long id;
    /** Corresponding structure component.  */
    long mComponent;
    /** Date of assessment.  */
    double mAssessmentDate;
    /** Repair option.  */
    ComponentRepairOption mComponentRepairOption;
    /** Repair description.  */
    string mRepairDesc;
  };
  /** Data type for holding a list of StructureComponentRepairOption fields structures. */
  sequence<StructureComponentRepairOptionFields> StructureComponentRepairOptionFieldsList;

  /**
   * StructureTraffic fields structure.
   */
  struct StructureTrafficFields {
    /** Unique identifier (for internal use only). */
    long id;
    /** Corresponding structure.  */
    long mStructure;
    /** Date of assessment.  */
    double mAssessmentDate;
    /** Average annual daily traffic count for structure.  */
    float mAADT;
    /** Average annual daily truck count for structure.  */
    float mAADTT;
    /** Expected traffic growth or decline used in the modeling.  */
    float mTrafficChange;
    /** Real economic discount rate applied over bridge life cycle.  */
    float mDiscountRate;
  };
  /** Data type for holding a list of StructureTraffic fields structures. */
  sequence<StructureTrafficFields> StructureTrafficFieldsList;

  /**
   * StructureComponentRepair fields structure.
   */
  struct StructureComponentRepairFields {
    /** Unique identifier (for internal use only). */
    long id;
    /** Corresponding structure component.  */
    long mComponent;
    /** Date of assessment.  */
    double mAssessmentDate;
    /**  */
    ComponentRepairOption mComponentRepairOption;
    /**  */
    float mRepairDays;
    /**  */
    float mEconomicCost;
    /**  */
    float mAvailability;
  };
  /** Data type for holding a list of StructureComponentRepair fields structures. */
  sequence<StructureComponentRepairFields> StructureComponentRepairFieldsList;

  /**
   * ComponentInspElementAssessment fields structure.
   */
  struct ComponentInspElementAssessmentFields {
    /** Unique identifier (for internal use only). */
    long id;
    /** Corresponding component inspection element.  */
    long mInspElement;
    /** Corresponding bridge inspection  */
    long mBridgeInspection;
    /**  */
    float mRating;
    /**  */
    string mNotes;
  };
  /** Data type for holding a list of ComponentInspElementAssessment fields structures. */
  sequence<ComponentInspElementAssessmentFields> ComponentInspElementAssessmentFieldsList;

  /**
   * InspectionMultimedia fields structure.
   */
  struct InspectionMultimediaFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    long mBridgeInspection;
  };
  /** Data type for holding a list of InspectionMultimedia fields structures. */
  sequence<InspectionMultimediaFields> InspectionMultimediaFieldsList;

  /**
   * BridgeInspectionMultimedia fields structure.
   */
  struct BridgeInspectionMultimediaFields {
    /** Unique identifier (for internal use only). */
    long id;
    /** Corresponding structure.  */
    long mStructure;
    /** Corresponding inspection multi-media.  */
    long mInspectionMultimedia;
  };
  /** Data type for holding a list of BridgeInspectionMultimedia fields structures. */
  sequence<BridgeInspectionMultimediaFields> BridgeInspectionMultimediaFieldsList;

  /**
   * ComponentInspectionMultimedia fields structure.
   */
  struct ComponentInspectionMultimediaFields {
    /** Unique identifier (for internal use only). */
    long id;
    /** Corresponding component  */
    long mComponent;
    /** Corresponding inspection multimedia  */
    long mInspectionMultimedia;
  };
  /** Data type for holding a list of ComponentInspectionMultimedia fields structures. */
  sequence<ComponentInspectionMultimediaFields> ComponentInspectionMultimediaFieldsList;

  /**
   * ElementInspectionMultimedia fields structure.
   */
  struct ElementInspectionMultimediaFields {
    /** Unique identifier (for internal use only). */
    long id;
    /** Corresponding element  */
    long mInspElement;
    /** Corresponding inspection multimedia  */
    long mInspectionMultimedia;
  };
  /** Data type for holding a list of ElementInspectionMultimedia fields structures. */
  sequence<ElementInspectionMultimediaFields> ElementInspectionMultimediaFieldsList;

  /**
   * InspectionObservation fields structure.
   */
  struct InspectionObservationFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    InspObservationType mInspObservationType;
    /**  */
    float mObservationQty;
  };
  /** Data type for holding a list of InspectionObservation fields structures. */
  sequence<InspectionObservationFields> InspectionObservationFieldsList;

  /**
   * InspectionMultimediaTags fields structure.
   */
  struct InspectionMultimediaTagsFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    long mInspectionMultimedia;
    /**  */
    long mObservation;
    /**  */
    float mXCoordinate;
    /**  */
    float mYCoordinate;
  };
  /** Data type for holding a list of InspectionMultimediaTags fields structures. */
  sequence<InspectionMultimediaTagsFields> InspectionMultimediaTagsFieldsList;

  /**
   * StructureComponentPoint fields structure.
   */
  struct StructureComponentPointFields {
    /** Unique identifier (for internal use only). */
    long id;
    /** Structure components  */
    long mComponent;
    /** X coordinate  */
    float mXCoordinate;
    /** Y coordinate  */
    float mYCoordinate;
    /** Z coordinate  */
    float mZCoordinate;
  };
  /** Data type for holding a list of StructureComponentPoint fields structures. */
  sequence<StructureComponentPointFields> StructureComponentPointFieldsList;

  /**
   * StructureComponentCADModel fields structure.
   */
  struct StructureComponentCADModelFields {
    /** Unique identifier (for internal use only). */
    long id;
    /**  */
    long mComponent;
  };
  /** Data type for holding a list of StructureComponentCADModel fields structures. */
  sequence<StructureComponentCADModelFields> StructureComponentCADModelFieldsList;

  /**
   * CompRepairFinalCond fields structure.
   */
  struct CompRepairFinalCondFields {
    /** Unique identifier (for internal use only). */
    long id;
    /** Corresponding Component.  */
    long mStructureComponent;
    /**  */
    int mFinalCondition;
    /**  */
    float mBestEstimateCost;
  };
  /** Data type for holding a list of CompRepairFinalCond fields structures. */
  sequence<CompRepairFinalCondFields> CompRepairFinalCondFieldsList;

  /**
   * CompRepairTimelineMatrix fields structure.
   */
  struct CompRepairTimelineMatrixFields {
    /** Unique identifier (for internal use only). */
    long id;
    /** Corresponding Component.  */
    long mStructureComponent;
    /**  */
    OptimizationObjective mOptimizationObjective;
    /**  */
    double mAssessmentDate;
    /**  */
    double mYearOfAction;
    /**  */
    ComponentRepairOption mComponentRepairOption;
    /**  */
    float mRepairOptimizedValue;
  };
  /** Data type for holding a list of CompRepairTimelineMatrix fields structures. */
  sequence<CompRepairTimelineMatrixFields> CompRepairTimelineMatrixFieldsList;

  /**
   * CompEnvBurdenMatrix fields structure.
   */
  struct CompEnvBurdenMatrixFields {
    /** Unique identifier (for internal use only). */
    long id;
    /** Corresponding Component.  */
    long mStructureComponent;
    /**  */
    OptimizationObjective mOptimizationObjective;
    /**  */
    double mAssessmentDate;
    /**  */
    EnvImpactType mEnvImpactType;
    /**  */
    Unit mUnits;
    /**  */
    float mEnvOptimizeValue;
  };
  /** Data type for holding a list of CompEnvBurdenMatrix fields structures. */
  sequence<CompEnvBurdenMatrixFields> CompEnvBurdenMatrixFieldsList;

  /**
   * WeighInMotionStation fields structure.
   */
  struct WeighInMotionStationFields {
    /** Unique identifier (for internal use only). */
    long id;
    /** Corresponding structure.  */
    long mStructure;
    /** State code (26 is Michigan state code).  */
    int mStateCode;
    /** County code.  */
    int mCountyCode;
    /** Station ID.  */
    int mStationID;
  };
  /** Data type for holding a list of WeighInMotionStation fields structures. */
  sequence<WeighInMotionStationFields> WeighInMotionStationFieldsList;

  /**
   * WeighInMotionSensorData fields structure.
   */
  struct WeighInMotionSensorDataFields {
    /** Unique identifier (for internal use only). */
    long id;
    /** Record data type ('W'=Weight).  */
    string mRecordType;
    /** WIMS Station.  */
    long mStation;
    /** Collection time stamp.  */
    double mCollectTime;
    /** Travel direction of lane.  */
    CompassDirection mLaneDirection;
    /** Lane number.  */
    int mLaneNumber;
    /** Vehicle class.  */
    int mVehicleClass;
    /** Speed in MPH.  */
    int mSpeed;
    /** Gross weight in 100 pound units.  */
    int mGrossWeight;
    /** Number of axles.  */
    int mNumberOfAxles;
    /** Weight at axle 1 in 100 pound units.  */
    int mWeightAxle1;
    /** Weight at axle 2 in 100 pound units.  */
    int mWeightAxle2;
    /** Weight at axle 3 in 100 pound units.  */
    int mWeightAxle3;
    /** Weight at axle 4 in 100 pound units.  */
    int mWeightAxle4;
    /** Weight at axle 5 in 100 pound units.  */
    int mWeightAxle5;
    /** Weight at axle 6 in 100 pound units.  */
    int mWeightAxle6;
    /** Weight at axle 7 in 100 pound units.  */
    int mWeightAxle7;
    /** Weight at axle 8 in 100 pound units.  */
    int mWeightAxle8;
    /** Weight at axle 9 in 100 pound units.  */
    int mWeightAxle9;
    /** Weight at axle 10 in 100 pound units.  */
    int mWeightAxle10;
    /** Weight at axle 11 in 100 pound units.  */
    int mWeightAxle11;
    /** Weight at axle 12 in 100 pound units.  */
    int mWeightAxle12;
    /** Weight at axle 13 in 100 pound units.  */
    int mWeightAxle13;
    /** Spacing between axles 1 and 2 in 0.1 feet units.  */
    int mAxleSpacing1to2;
    /** Spacing between axles 2 and 3 in 0.1 feet units.  */
    int mAxleSpacing2to3;
    /** Spacing between axles 3 and 4 in 0.1 feet units.  */
    int mAxleSpacing3to4;
    /** Spacing between axles 4 and 5 in 0.1 feet units.  */
    int mAxleSpacing4to5;
    /** Spacing between axles 5 and 6 in 0.1 feet units.  */
    int mAxleSpacing5to6;
    /** Spacing between axles 6 and 7 in 0.1 feet units.  */
    int mAxleSpacing6to7;
    /** Spacing between axles 7 and 8 in 0.1 feet units.  */
    int mAxleSpacing7to8;
    /** Spacing between axles 8 and 9 in 0.1 feet units.  */
    int mAxleSpacing8to9;
    /** Spacing between axles 9 and 10 in 0.1 feet units.  */
    int mAxleSpacing9to10;
    /** Spacing between axles 10 and 11 in 0.1 feet units.  */
    int mAxleSpacing10to11;
    /** Spacing between axles 11 and 12 in 0.1 feet units.  */
    int mAxleSpacing11to12;
    /** Spacing between axles 12 and 13 in 0.1 feet units.  */
    int mAxleSpacing12to13;
  };
  /** Data type for holding a list of WeighInMotionSensorData fields structures. */
  sequence<WeighInMotionSensorDataFields> WeighInMotionSensorDataFieldsList;

  /**
   * MappingMatrix fields structure.
   *
   * Note that the array data is not included here.
   * See [MappingMatrix] to access the array data.
   */
  struct MappingMatrixFields {
    /** Unique identifier (for internal use only). */
    long id;
    /** Parent structure  */
    long mStructure;
    /** Short name  */
    string mName;
    /** Description  */
    string mDescription;
    /** Output quantity  */
    Quantity mOutputQuantity;
    /** Input quantity  */
    Quantity mInputQuantity;
  };
  /** Data type for holding a list of MappingMatrix fields structures. */
  sequence<MappingMatrixFields> MappingMatrixFieldsList;

  /**
   * MeasurementCycle fields structure.
   *
   * Note that the array data is not included here.
   * See [MeasurementCycle] to access the array data.
   */
  struct MeasurementCycleFields {
    /** Unique identifier (for internal use only). */
    long id;
    /** * Structure where the measurement was taken.
    */
    long mStructure;
    /** * Start date and time of measurement.
    */
    double mStart;
    /** * Sampling interval [s].
    */
    float mTS;
    /** * Number of samples taken.
    */
    int mSamples;
  };
  /** Data type for holding a list of MeasurementCycle fields structures. */
  sequence<MeasurementCycleFields> MeasurementCycleFieldsList;

  /**
   * StaticLoadToSensorMapping fields structure.
   *
   * Note that the array data is not included here.
   * See [StaticLoadToSensorMapping] to access the array data.
   */
  struct StaticLoadToSensorMappingFields {
    /** Unique identifier (for internal use only). */
    long id;
    /** Corresponding structure.  */
    long mStructure;
    /** Date of computation.  */
    double mDate;
  };
  /** Data type for holding a list of StaticLoadToSensorMapping fields structures. */
  sequence<StaticLoadToSensorMappingFields> StaticLoadToSensorMappingFieldsList;

  /**
   * DaqUnitChannelData fields structure.
   *
   * Note that the signal data is not included here.
   * See [DaqUnitChannelData] to access the signal data.
   */
  struct DaqUnitChannelDataFields {
    /** Unique identifier (for internal use only). */
    long id;
    /** * Parent DAQ unit channel.
    */
    long mChannel;
  };
  /** Data type for holding a list of DaqUnitChannelData fields structures. */
  sequence<DaqUnitChannelDataFields> DaqUnitChannelDataFieldsList;

  /**
   * SensorChannelData fields structure.
   *
   * Note that the signal data is not included here.
   * See [SensorChannelData] to access the signal data.
   */
  struct SensorChannelDataFields {
    /** Unique identifier (for internal use only). */
    long id;
    /** * Parent DAQ unit channel.
    */
    long mChannel;
  };
  /** Data type for holding a list of SensorChannelData fields structures. */
  sequence<SensorChannelDataFields> SensorChannelDataFieldsList;

  /**
   * User group. 
   *
   */
  interface UserGroup {
    /**
     * Gets the fields of this UserGroup object.
     *
     * @return UserGroup object fields
     */
    idempotent UserGroupFields getFields() throws ServerError;

    /**
     * Updates the fields of this UserGroup object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Name</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(UserGroupFields fields,
        FieldNameList fieldNames) throws ServerError;
  };

  /**
   * User. 
   *
   */
  interface User {
    /**
     * Gets the fields of this User object.
     *
     * @return User object fields
     */
    idempotent UserFields getFields() throws ServerError;

    /**
     * Updates the fields of this User object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>UserName</li>
     * <li>EmailAddress</li>
     * <li>Password</li>
     * <li>Salt</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(UserFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the IDs of the [UserGroupMembership] child objects.
     *
     * The child objects refer to this object.
     *
     * @return list of [UserGroupMembership] child object IDs
     */
    idempotent IdList getUserGroupMembershipChildIds() throws ServerError;

    /**
     * Gets the IDs of the [NotificationMembership] child objects.
     *
     * The child objects refer to this object.
     *
     * @return list of [NotificationMembership] child object IDs
     */
    idempotent IdList getNotificationMembershipChildIds() throws ServerError;
  };

  /**
   * User group membership for access control. 
   *
   */
  interface UserGroupMembership {
    /**
     * Gets the fields of this UserGroupMembership object.
     *
     * @return UserGroupMembership object fields
     */
    idempotent UserGroupMembershipFields getFields() throws ServerError;

    /**
     * Updates the fields of this UserGroupMembership object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>User</li>
     * <li>Group</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(UserGroupMembershipFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [User] object refered to by the
     * User field.
     *
     * @return User interface
     */
    idempotent User* getUser() throws ServerError;

    /**
     * Gets the proxy to the [UserGroup] object refered to by the
     * Group field.
     *
     * @return Group interface
     */
    idempotent UserGroup* getGroup() throws ServerError;
  };

  /**
   * Notification category. 
   *
   */
  interface NotificationCategory {
    /**
     * Gets the fields of this NotificationCategory object.
     *
     * @return NotificationCategory object fields
     */
    idempotent NotificationCategoryFields getFields() throws ServerError;

    /**
     * Updates the fields of this NotificationCategory object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Name</li>
     * <li>Description</li>
     * <li>Enabled</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(NotificationCategoryFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a Messages file.
     *
     * Use the returned file ID to get a writer interface
     * to send the file contents
     * to the server.
     *
     * @param info file information (the size is ignored)
     * @return file ID
     * @see getMessagesFileWriter()
     */
    long addMessagesFileInfo(FileInfo info) throws ServerError;

    /**
     * Deletes a Messages file if it exists.
     *
     * @param id  file ID
     */
    idempotent void rmMessagesFile(long id) throws ServerError;

    /**
     * Writes a block of data to a Messages file.
     *
     * @param id      file ID
     * @param offset  starting point of the read (file pointer offset)
     * @param data    data to write
     */
    idempotent void writeMessagesFile(long id, long offset, ByteSeq data) throws ServerError;

    /**
     * Gets information on a Messages file.
     *
     * @param id file ID
     * @return file information (empty if the file does not exist)
     */
    idempotent FileInfo getMessagesFileInfo(long id) throws ServerError;

    /**
     * Reads a block of data from a Messages file.
     *
     * This method may return less than the requested number of bytes
     * if the end of the file is reached.
     *
     * @param id      file ID
     * @param offset  starting point of the read (file pointer offset)
     * @param count   number of bytes to read
     */
    idempotent ByteSeq readMessagesFile(long id, long offset, int count) throws ServerError;

    /**
     * Gets the Messages file info list for the given time range.
     *
     * @param tStart  start of time range \[s]
     * @param tStop   end of time range \[s]
     * @return file information list
     */
    idempotent FileInfoList getMessagesFileInfoList(double tStart, double tStop);
  };

  /**
   * Notification category user membership. 
   *
   */
  interface NotificationMembership {
    /**
     * Gets the fields of this NotificationMembership object.
     *
     * @return NotificationMembership object fields
     */
    idempotent NotificationMembershipFields getFields() throws ServerError;

    /**
     * Updates the fields of this NotificationMembership object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>User</li>
     * <li>Category</li>
     * <li>Enabled</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(NotificationMembershipFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [User] object refered to by the
     * User field.
     *
     * @return User interface
     */
    idempotent User* getUser() throws ServerError;

    /**
     * Gets the proxy to the [NotificationCategory] object refered to by the
     * Category field.
     *
     * @return Category interface
     */
    idempotent NotificationCategory* getCategory() throws ServerError;
  };

  /**
   * Structure owner, such as a DOT. 
   *
   */
  interface StructureOwner {
    /**
     * Gets the fields of this StructureOwner object.
     *
     * @return StructureOwner object fields
     */
    idempotent StructureOwnerFields getFields() throws ServerError;

    /**
     * Updates the fields of this StructureOwner object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Name</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(StructureOwnerFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the IDs of the [Structure] child objects.
     *
     * The child objects refer to this object.
     *
     * @return list of [Structure] child object IDs
     */
    idempotent IdList getStructureChildIds() throws ServerError;
  };

  /**
   * Structure, such as a bridge. 
   *
   */
  interface Structure {
    /**
     * Gets the fields of this Structure object.
     *
     * @return Structure object fields
     */
    idempotent StructureFields getFields() throws ServerError;

    /**
     * Updates the fields of this Structure object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Name</li>
     * <li>Description</li>
     * <li>Type</li>
     * <li>DistanceUnit</li>
     * <li>ForceUnit</li>
     * <li>WeightUnit</li>
     * <li>Owner</li>
     * <li>DateBuilt</li>
     * <li>Latitude</li>
     * <li>Longitude</li>
     * <li>Location</li>
     * <li>StateStructID</li>
     * <li>FedStructID</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(StructureFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [StructureOwner] object refered to by the
     * Owner field.
     *
     * @return Owner interface
     */
    idempotent StructureOwner* getOwner() throws ServerError;

    /**
     * Gets the IDs of the [BridgeDetails] child objects.
     *
     * The child objects refer to this object.
     *
     * @return list of [BridgeDetails] child object IDs
     */
    idempotent IdList getBridgeDetailsChildIds() throws ServerError;

    /**
     * Gets the IDs of the [StructureAssessment] child objects.
     *
     * The child objects refer to this object.
     *
     * @return list of [StructureAssessment] child object IDs
     */
    idempotent IdList getStructureAssessmentChildIds() throws ServerError;

    /**
     * Gets the IDs of the [StructureRetrofit] child objects.
     *
     * The child objects refer to this object.
     *
     * @return list of [StructureRetrofit] child object IDs
     */
    idempotent IdList getStructureRetrofitChildIds() throws ServerError;

    /**
     * Gets the IDs of the [StructureComponent] child objects.
     *
     * The child objects refer to this object.
     *
     * @return list of [StructureComponent] child object IDs
     */
    idempotent IdList getStructureComponentChildIds() throws ServerError;

    /**
     * Gets the IDs of the [StructureTraffic] child objects.
     *
     * The child objects refer to this object.
     *
     * @return list of [StructureTraffic] child object IDs
     */
    idempotent IdList getStructureTrafficChildIds() throws ServerError;

    /**
     * Gets the IDs of the [WeighInMotionStation] child objects.
     *
     * The child objects refer to this object.
     *
     * @return list of [WeighInMotionStation] child object IDs
     */
    idempotent IdList getWeighInMotionStationChildIds() throws ServerError;

    /**
     * Gets the IDs of the [MeasurementCycle] child objects.
     *
     * The child objects refer to this object.
     *
     * @return list of [MeasurementCycle] child object IDs
     */
    idempotent IdList getMeasurementCycleChildIds() throws ServerError;

    /**
     * Gets the IDs of the [StaticLoadToSensorMapping] child objects.
     *
     * The child objects refer to this object.
     *
     * @return list of [StaticLoadToSensorMapping] child object IDs
     */
    idempotent IdList getStaticLoadToSensorMappingChildIds() throws ServerError;

    /**
     * Adds a Drawings file.
     *
     * Use the returned file ID to get a writer interface
     * to send the file contents
     * to the server.
     *
     * @param info file information (the size is ignored)
     * @return file ID
     * @see getDrawingsFileWriter()
     */
    long addDrawingsFileInfo(FileInfo info) throws ServerError;

    /**
     * Deletes a Drawings file if it exists.
     *
     * @param id  file ID
     */
    idempotent void rmDrawingsFile(long id) throws ServerError;

    /**
     * Writes a block of data to a Drawings file.
     *
     * @param id      file ID
     * @param offset  starting point of the read (file pointer offset)
     * @param data    data to write
     */
    idempotent void writeDrawingsFile(long id, long offset, ByteSeq data) throws ServerError;

    /**
     * Gets information on a Drawings file.
     *
     * @param id file ID
     * @return file information (empty if the file does not exist)
     */
    idempotent FileInfo getDrawingsFileInfo(long id) throws ServerError;

    /**
     * Reads a block of data from a Drawings file.
     *
     * This method may return less than the requested number of bytes
     * if the end of the file is reached.
     *
     * @param id      file ID
     * @param offset  starting point of the read (file pointer offset)
     * @param count   number of bytes to read
     */
    idempotent ByteSeq readDrawingsFile(long id, long offset, int count) throws ServerError;

    /**
     * Gets the Drawings file info list for the given time range.
     *
     * @param tStart  start of time range \[s]
     * @param tStop   end of time range \[s]
     * @return file information list
     */
    idempotent FileInfoList getDrawingsFileInfoList(double tStart, double tStop);
  };

  /**
   * Finite element model degrees of freedom. 
   *
   */
  interface FEMDof {
    /**
     * Gets the fields of this FEMDof object.
     *
     * @return FEMDof object fields
     */
    idempotent FEMDofFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMDof object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Structure</li>
     * <li>LocalId</li>
     * <li>Node</li>
     * <li>Direction</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMDofFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [Structure] object refered to by the
     * Structure field.
     *
     * @return Structure interface
     */
    idempotent Structure* getStructure() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * Node field.
     *
     * @return Node interface
     */
    idempotent FEMNode* getNode() throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMNodalMass {
    /**
     * Gets the fields of this FEMNodalMass object.
     *
     * @return FEMNodalMass object fields
     */
    idempotent FEMNodalMassFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMNodalMass object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Description</li>
     * <li>Mass1</li>
     * <li>Mass2</li>
     * <li>Mass3</li>
     * <li>Mass4</li>
     * <li>Mass5</li>
     * <li>Mass6</li>
     * <li>Node</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMNodalMassFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * Node field.
     *
     * @return Node interface
     */
    idempotent FEMNode* getNode() throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMNLElasticStrainStress {
    /**
     * Gets the fields of this FEMNLElasticStrainStress object.
     *
     * @return FEMNLElasticStrainStress object fields
     */
    idempotent FEMNLElasticStrainStressFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMNLElasticStrainStress object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>MaterialID</li>
     * <li>RecordNumber</li>
     * <li>Strain</li>
     * <li>Stress</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMNLElasticStrainStressFields fields,
        FieldNameList fieldNames) throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMBoundary {
    /**
     * Gets the fields of this FEMBoundary object.
     *
     * @return FEMBoundary object fields
     */
    idempotent FEMBoundaryFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMBoundary object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Node</li>
     * <li>Ovalization</li>
     * <li>Phi</li>
     * <li>Rx</li>
     * <li>Ry</li>
     * <li>Rz</li>
     * <li>Ux</li>
     * <li>Uy</li>
     * <li>Uz</li>
     * <li>Warping</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMBoundaryFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * Node field.
     *
     * @return Node interface
     */
    idempotent FEMNode* getNode() throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMSectionPipe {
    /**
     * Gets the fields of this FEMSectionPipe object.
     *
     * @return FEMSectionPipe object fields
     */
    idempotent FEMSectionPipeFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMSectionPipe object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Diameter</li>
     * <li>SC</li>
     * <li>Section</li>
     * <li>SSarea</li>
     * <li>TC</li>
     * <li>Thickness</li>
     * <li>Torfac</li>
     * <li>TSarea</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMSectionPipeFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [FEMCrossSection] object refered to by the
     * Section field.
     *
     * @return Section interface
     */
    idempotent FEMCrossSection* getSection() throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMCoordSystem {
    /**
     * Gets the fields of this FEMCoordSystem object.
     *
     * @return FEMCoordSystem object fields
     */
    idempotent FEMCoordSystemFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMCoordSystem object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>AX</li>
     * <li>AY</li>
     * <li>AZ</li>
     * <li>BBY</li>
     * <li>BX</li>
     * <li>BZ</li>
     * <li>Description</li>
     * <li>Mode</li>
     * <li>P1</li>
     * <li>P2</li>
     * <li>P3</li>
     * <li>Type</li>
     * <li>Xorigin</li>
     * <li>Yorigin</li>
     * <li>Zorigin</li>
     * <li>LocalID</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMCoordSystemFields fields,
        FieldNameList fieldNames) throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMNode {
    /**
     * Gets the fields of this FEMNode object.
     *
     * @return FEMNode object fields
     */
    idempotent FEMNodeFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMNode object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Description</li>
     * <li>System</li>
     * <li>X</li>
     * <li>Y</li>
     * <li>Z</li>
     * <li>LocalID</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMNodeFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [FEMCoordSystem] object refered to by the
     * System field.
     *
     * @return System interface
     */
    idempotent FEMCoordSystem* getSystem() throws ServerError;

    /**
     * Gets the IDs of the [FixedCamera] child objects.
     *
     * The child objects refer to this object.
     *
     * @return list of [FixedCamera] child object IDs
     */
    idempotent IdList getFixedCameraChildIds() throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMTruss {
    /**
     * Gets the fields of this FEMTruss object.
     *
     * @return FEMTruss object fields
     */
    idempotent FEMTrussFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMTruss object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Description</li>
     * <li>ElementID</li>
     * <li>Epsin</li>
     * <li>Gapwidth</li>
     * <li>Group</li>
     * <li>Material</li>
     * <li>N1</li>
     * <li>N2</li>
     * <li>RecordNmb</li>
     * <li>Save</li>
     * <li>SectionArea</li>
     * <li>TBirth</li>
     * <li>TDeath</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMTrussFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [FEMGroup] object refered to by the
     * Group field.
     *
     * @return Group interface
     */
    idempotent FEMGroup* getGroup() throws ServerError;

    /**
     * Gets the proxy to the [FEMMaterial] object refered to by the
     * Material field.
     *
     * @return Material interface
     */
    idempotent FEMMaterial* getMaterial() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * N1 field.
     *
     * @return N1 interface
     */
    idempotent FEMNode* getN1() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * N2 field.
     *
     * @return N2 interface
     */
    idempotent FEMNode* getN2() throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMTimeFunctionData {
    /**
     * Gets the fields of this FEMTimeFunctionData object.
     *
     * @return FEMTimeFunctionData object fields
     */
    idempotent FEMTimeFunctionDataFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMTimeFunctionData object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>DataTime</li>
     * <li>GMRecordID</li>
     * <li>RecordNmb</li>
     * <li>TimeFunctionID</li>
     * <li>TimeValue</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMTimeFunctionDataFields fields,
        FieldNameList fieldNames) throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMPlasticMlMaterials {
    /**
     * Gets the fields of this FEMPlasticMlMaterials object.
     *
     * @return FEMPlasticMlMaterials object fields
     */
    idempotent FEMPlasticMlMaterialsFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMPlasticMlMaterials object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>ALPHA</li>
     * <li>Density</li>
     * <li>E</li>
     * <li>Hardening</li>
     * <li>MaterialID</li>
     * <li>NU</li>
     * <li>TREF</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMPlasticMlMaterialsFields fields,
        FieldNameList fieldNames) throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMPlateGroup {
    /**
     * Gets the fields of this FEMPlateGroup object.
     *
     * @return FEMPlateGroup object fields
     */
    idempotent FEMPlateGroupFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMPlateGroup object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Displacement</li>
     * <li>Group</li>
     * <li>IniStrain</li>
     * <li>MaterialID</li>
     * <li>Result</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMPlateGroupFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [FEMGroup] object refered to by the
     * Group field.
     *
     * @return Group interface
     */
    idempotent FEMGroup* getGroup() throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMBeam {
    /**
     * Gets the fields of this FEMBeam object.
     *
     * @return FEMBeam object fields
     */
    idempotent FEMBeamFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMBeam object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>AuxNode</li>
     * <li>Description</li>
     * <li>ElementID</li>
     * <li>EndRelease</li>
     * <li>Epsin</li>
     * <li>Group</li>
     * <li>IRigidEnd</li>
     * <li>JRigidEnd</li>
     * <li>Material</li>
     * <li>Node1</li>
     * <li>Node2</li>
     * <li>RecordNmb</li>
     * <li>Save</li>
     * <li>Section</li>
     * <li>Subdivision</li>
     * <li>TBirth</li>
     * <li>TDeath</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMBeamFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * AuxNode field.
     *
     * @return AuxNode interface
     */
    idempotent FEMNode* getAuxNode() throws ServerError;

    /**
     * Gets the proxy to the [FEMEndRelease] object refered to by the
     * EndRelease field.
     *
     * @return EndRelease interface
     */
    idempotent FEMEndRelease* getEndRelease() throws ServerError;

    /**
     * Gets the proxy to the [FEMGroup] object refered to by the
     * Group field.
     *
     * @return Group interface
     */
    idempotent FEMGroup* getGroup() throws ServerError;

    /**
     * Gets the proxy to the [FEMMaterial] object refered to by the
     * Material field.
     *
     * @return Material interface
     */
    idempotent FEMMaterial* getMaterial() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * Node1 field.
     *
     * @return Node1 interface
     */
    idempotent FEMNode* getNode1() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * Node2 field.
     *
     * @return Node2 interface
     */
    idempotent FEMNode* getNode2() throws ServerError;

    /**
     * Gets the proxy to the [FEMCrossSection] object refered to by the
     * Section field.
     *
     * @return Section interface
     */
    idempotent FEMCrossSection* getSection() throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMCurvMomentData {
    /**
     * Gets the fields of this FEMCurvMomentData object.
     *
     * @return FEMCurvMomentData object fields
     */
    idempotent FEMCurvMomentDataFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMCurvMomentData object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Curvature</li>
     * <li>CurvMomentID</li>
     * <li>Moment</li>
     * <li>RecordNmb</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMCurvMomentDataFields fields,
        FieldNameList fieldNames) throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMPropertysets {
    /**
     * Gets the fields of this FEMPropertysets object.
     *
     * @return FEMPropertysets object fields
     */
    idempotent FEMPropertysetsFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMPropertysets object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>C</li>
     * <li>Description</li>
     * <li>K</li>
     * <li>M</li>
     * <li>NC</li>
     * <li>NK</li>
     * <li>NM</li>
     * <li>Nonlinear</li>
     * <li>PropertysetID</li>
     * <li>S</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMPropertysetsFields fields,
        FieldNameList fieldNames) throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMOrthotropicMaterial {
    /**
     * Gets the fields of this FEMOrthotropicMaterial object.
     *
     * @return FEMOrthotropicMaterial object fields
     */
    idempotent FEMOrthotropicMaterialFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMOrthotropicMaterial object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Density</li>
     * <li>EA</li>
     * <li>EB</li>
     * <li>EC</li>
     * <li>GAB</li>
     * <li>GAC</li>
     * <li>GBC</li>
     * <li>Material</li>
     * <li>NUAB</li>
     * <li>NUAC</li>
     * <li>NUBC</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMOrthotropicMaterialFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [FEMMaterial] object refered to by the
     * Material field.
     *
     * @return Material interface
     */
    idempotent FEMMaterial* getMaterial() throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMAppliedLoads {
    /**
     * Gets the fields of this FEMAppliedLoads object.
     *
     * @return FEMAppliedLoads object fields
     */
    idempotent FEMAppliedLoadsFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMAppliedLoads object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>AppliedLoadNmb</li>
     * <li>ArrivalTime</li>
     * <li>LoadID</li>
     * <li>LoadType</li>
     * <li>SiteType</li>
     * <li>TimeFunctionID</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMAppliedLoadsFields fields,
        FieldNameList fieldNames) throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMThermoOrthData {
    /**
     * Gets the fields of this FEMThermoOrthData object.
     *
     * @return FEMThermoOrthData object fields
     */
    idempotent FEMThermoOrthDataFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMThermoOrthData object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>ALPHAA</li>
     * <li>ALPHAB</li>
     * <li>ALPHAC</li>
     * <li>EA</li>
     * <li>EB</li>
     * <li>EC</li>
     * <li>GAB</li>
     * <li>GAC</li>
     * <li>GBC</li>
     * <li>MaterialID</li>
     * <li>NUAB</li>
     * <li>NUAC</li>
     * <li>NUBC</li>
     * <li>RecordNmb</li>
     * <li>Theta</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMThermoOrthDataFields fields,
        FieldNameList fieldNames) throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMContactPairs {
    /**
     * Gets the fields of this FEMContactPairs object.
     *
     * @return FEMContactPairs object fields
     */
    idempotent FEMContactPairsFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMContactPairs object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>ContactorSurf</li>
     * <li>ContGroupID</li>
     * <li>ContPair</li>
     * <li>FContactor</li>
     * <li>Friction</li>
     * <li>FTarget</li>
     * <li>HeatTransf</li>
     * <li>RecordNmb</li>
     * <li>TargetSurf</li>
     * <li>TBirth</li>
     * <li>TDeath</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMContactPairsFields fields,
        FieldNameList fieldNames) throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMGeneral {
    /**
     * Gets the fields of this FEMGeneral object.
     *
     * @return FEMGeneral object fields
     */
    idempotent FEMGeneralFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMGeneral object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Description</li>
     * <li>ElementID</li>
     * <li>Group</li>
     * <li>MatrixSet</li>
     * <li>NodeAmount</li>
     * <li>RecordNmb</li>
     * <li>Save</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMGeneralFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [FEMGroup] object refered to by the
     * Group field.
     *
     * @return Group interface
     */
    idempotent FEMGroup* getGroup() throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMBeamGroup {
    /**
     * Gets the fields of this FEMBeamGroup object.
     *
     * @return FEMBeamGroup object fields
     */
    idempotent FEMBeamGroupFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMBeamGroup object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Displacement</li>
     * <li>Group</li>
     * <li>IniStrain</li>
     * <li>MaterialID</li>
     * <li>MC</li>
     * <li>MCrigidity</li>
     * <li>REmultiplyer</li>
     * <li>Result</li>
     * <li>REtype</li>
     * <li>RINT</li>
     * <li>SectionID</li>
     * <li>SINT</li>
     * <li>TINT</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMBeamGroupFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [FEMGroup] object refered to by the
     * Group field.
     *
     * @return Group interface
     */
    idempotent FEMGroup* getGroup() throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMSectionRect {
    /**
     * Gets the fields of this FEMSectionRect object.
     *
     * @return FEMSectionRect object fields
     */
    idempotent FEMSectionRectFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMSectionRect object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Height</li>
     * <li>IShear</li>
     * <li>SC</li>
     * <li>Section</li>
     * <li>SSarea</li>
     * <li>TC</li>
     * <li>Torfac</li>
     * <li>TSarea</li>
     * <li>Width</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMSectionRectFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [FEMCrossSection] object refered to by the
     * Section field.
     *
     * @return Section interface
     */
    idempotent FEMCrossSection* getSection() throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMBeamLoad {
    /**
     * Gets the fields of this FEMBeamLoad object.
     *
     * @return FEMBeamLoad object fields
     */
    idempotent FEMBeamLoadFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMBeamLoad object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>ArrivalTime</li>
     * <li>DeformDepend</li>
     * <li>DirectFilter</li>
     * <li>ElementID</li>
     * <li>Face</li>
     * <li>Group</li>
     * <li>P1</li>
     * <li>P2</li>
     * <li>RecordNmb</li>
     * <li>TimeFunctionID</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMBeamLoadFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [FEMGroup] object refered to by the
     * Group field.
     *
     * @return Group interface
     */
    idempotent FEMGroup* getGroup() throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMLoadMassProportional {
    /**
     * Gets the fields of this FEMLoadMassProportional object.
     *
     * @return FEMLoadMassProportional object fields
     */
    idempotent FEMLoadMassProportionalFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMLoadMassProportional object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>AX</li>
     * <li>AY</li>
     * <li>AZ</li>
     * <li>LoadID</li>
     * <li>Magnitude</li>
     * <li>Structure</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMLoadMassProportionalFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [Structure] object refered to by the
     * Structure field.
     *
     * @return Structure interface
     */
    idempotent Structure* getStructure() throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMLink {
    /**
     * Gets the fields of this FEMLink object.
     *
     * @return FEMLink object fields
     */
    idempotent FEMLinkFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMLink object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Description</li>
     * <li>Displacement</li>
     * <li>MasterNode</li>
     * <li>RLID</li>
     * <li>SlaveNode</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMLinkFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * MasterNode field.
     *
     * @return MasterNode interface
     */
    idempotent FEMNode* getMasterNode() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * SlaveNode field.
     *
     * @return SlaveNode interface
     */
    idempotent FEMNode* getSlaveNode() throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMAxesNode {
    /**
     * Gets the fields of this FEMAxesNode object.
     *
     * @return FEMAxesNode object fields
     */
    idempotent FEMAxesNodeFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMAxesNode object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>AxNodeID</li>
     * <li>Group</li>
     * <li>Node1</li>
     * <li>Node2</li>
     * <li>Node3</li>
     * <li>RecordNmb</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMAxesNodeFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [FEMGroup] object refered to by the
     * Group field.
     *
     * @return Group interface
     */
    idempotent FEMGroup* getGroup() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * Node1 field.
     *
     * @return Node1 interface
     */
    idempotent FEMNode* getNode1() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * Node2 field.
     *
     * @return Node2 interface
     */
    idempotent FEMNode* getNode2() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * Node3 field.
     *
     * @return Node3 interface
     */
    idempotent FEMNode* getNode3() throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMNMTimeMass {
    /**
     * Gets the fields of this FEMNMTimeMass object.
     *
     * @return FEMNMTimeMass object fields
     */
    idempotent FEMNMTimeMassFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMNMTimeMass object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Mass</li>
     * <li>PropertyID</li>
     * <li>RecordNmb</li>
     * <li>TimeValue</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMNMTimeMassFields fields,
        FieldNameList fieldNames) throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMAppliedDisplacement {
    /**
     * Gets the fields of this FEMAppliedDisplacement object.
     *
     * @return FEMAppliedDisplacement object fields
     */
    idempotent FEMAppliedDisplacementFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMAppliedDisplacement object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>ArrivalTime</li>
     * <li>Description</li>
     * <li>Direction</li>
     * <li>Factor</li>
     * <li>Node</li>
     * <li>RecordNmb</li>
     * <li>TimeFunctionID</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMAppliedDisplacementFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * Node field.
     *
     * @return Node interface
     */
    idempotent FEMNode* getNode() throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMTimeFunctions {
    /**
     * Gets the fields of this FEMTimeFunctions object.
     *
     * @return FEMTimeFunctions object fields
     */
    idempotent FEMTimeFunctionsFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMTimeFunctions object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Description</li>
     * <li>TimeFunctionID</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMTimeFunctionsFields fields,
        FieldNameList fieldNames) throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMForceStrainData {
    /**
     * Gets the fields of this FEMForceStrainData object.
     *
     * @return FEMForceStrainData object fields
     */
    idempotent FEMForceStrainDataFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMForceStrainData object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Force</li>
     * <li>ForceAxID</li>
     * <li>RecordNmb</li>
     * <li>Strain</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMForceStrainDataFields fields,
        FieldNameList fieldNames) throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMSkewDOF {
    /**
     * Gets the fields of this FEMSkewDOF object.
     *
     * @return FEMSkewDOF object fields
     */
    idempotent FEMSkewDOFFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMSkewDOF object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Description</li>
     * <li>Node</li>
     * <li>SkewSystemID</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMSkewDOFFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * Node field.
     *
     * @return Node interface
     */
    idempotent FEMNode* getNode() throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMSectionI {
    /**
     * Gets the fields of this FEMSectionI object.
     *
     * @return FEMSectionI object fields
     */
    idempotent FEMSectionIFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMSectionI object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Height</li>
     * <li>SC</li>
     * <li>Section</li>
     * <li>SSarea</li>
     * <li>TC</li>
     * <li>Thick1</li>
     * <li>Thick2</li>
     * <li>Thick3</li>
     * <li>Torfac</li>
     * <li>TSarea</li>
     * <li>Width1</li>
     * <li>Width2</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMSectionIFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [FEMCrossSection] object refered to by the
     * Section field.
     *
     * @return Section interface
     */
    idempotent FEMCrossSection* getSection() throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMPlasticBilinearMaterial {
    /**
     * Gets the fields of this FEMPlasticBilinearMaterial object.
     *
     * @return FEMPlasticBilinearMaterial object fields
     */
    idempotent FEMPlasticBilinearMaterialFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMPlasticBilinearMaterial object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Alpha</li>
     * <li>Density</li>
     * <li>E</li>
     * <li>EPA</li>
     * <li>ET</li>
     * <li>Hardening</li>
     * <li>Material</li>
     * <li>NU</li>
     * <li>TRef</li>
     * <li>Yield</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMPlasticBilinearMaterialFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [FEMMaterial] object refered to by the
     * Material field.
     *
     * @return Material interface
     */
    idempotent FEMMaterial* getMaterial() throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMMTForceData {
    /**
     * Gets the fields of this FEMMTForceData object.
     *
     * @return FEMMTForceData object fields
     */
    idempotent FEMMTForceDataFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMMTForceData object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Force</li>
     * <li>MomentRID</li>
     * <li>RecordNmb</li>
     * <li>TwistMomentID</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMMTForceDataFields fields,
        FieldNameList fieldNames) throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMShellPressure {
    /**
     * Gets the fields of this FEMShellPressure object.
     *
     * @return FEMShellPressure object fields
     */
    idempotent FEMShellPressureFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMShellPressure object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>ArrivalTime</li>
     * <li>DeformDepend</li>
     * <li>Description</li>
     * <li>DirectFilter</li>
     * <li>ElementID</li>
     * <li>Face</li>
     * <li>Group</li>
     * <li>Nodaux</li>
     * <li>P1</li>
     * <li>P2</li>
     * <li>P3</li>
     * <li>P4</li>
     * <li>RecordNmb</li>
     * <li>TimeFunctionID</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMShellPressureFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [FEMGroup] object refered to by the
     * Group field.
     *
     * @return Group interface
     */
    idempotent FEMGroup* getGroup() throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMMatrices {
    /**
     * Gets the fields of this FEMMatrices object.
     *
     * @return FEMMatrices object fields
     */
    idempotent FEMMatricesFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMMatrices object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Description</li>
     * <li>Lump</li>
     * <li>MatrixID</li>
     * <li>MatrixType</li>
     * <li>ND</li>
     * <li>NS</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMMatricesFields fields,
        FieldNameList fieldNames) throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMDamping {
    /**
     * Gets the fields of this FEMDamping object.
     *
     * @return FEMDamping object fields
     */
    idempotent FEMDampingFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMDamping object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>ALPHA</li>
     * <li>BETA</li>
     * <li>Group</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMDampingFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [FEMGroup] object refered to by the
     * Group field.
     *
     * @return Group interface
     */
    idempotent FEMGroup* getGroup() throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMMaterial {
    /**
     * Gets the fields of this FEMMaterial object.
     *
     * @return FEMMaterial object fields
     */
    idempotent FEMMaterialFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMMaterial object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Description</li>
     * <li>MaterialType</li>
     * <li>LocalID</li>
     * <li>Structure</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMMaterialFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [Structure] object refered to by the
     * Structure field.
     *
     * @return Structure interface
     */
    idempotent Structure* getStructure() throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMMatrixData {
    /**
     * Gets the fields of this FEMMatrixData object.
     *
     * @return FEMMatrixData object fields
     */
    idempotent FEMMatrixDataFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMMatrixData object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Coeff</li>
     * <li>ColumnIndex</li>
     * <li>MatrixID</li>
     * <li>RecordNmb</li>
     * <li>RowIndex</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMMatrixDataFields fields,
        FieldNameList fieldNames) throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMShellAxesOrtho {
    /**
     * Gets the fields of this FEMShellAxesOrtho object.
     *
     * @return FEMShellAxesOrtho object fields
     */
    idempotent FEMShellAxesOrthoFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMShellAxesOrtho object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>ALFA</li>
     * <li>AxOrthoID</li>
     * <li>Group</li>
     * <li>LineID</li>
     * <li>RecordNmb</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMShellAxesOrthoFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [FEMGroup] object refered to by the
     * Group field.
     *
     * @return Group interface
     */
    idempotent FEMGroup* getGroup() throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMEndRelease {
    /**
     * Gets the fields of this FEMEndRelease object.
     *
     * @return FEMEndRelease object fields
     */
    idempotent FEMEndReleaseFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMEndRelease object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Description</li>
     * <li>Moment1</li>
     * <li>Moment2</li>
     * <li>Moment3</li>
     * <li>Moment4</li>
     * <li>Moment5</li>
     * <li>Moment6</li>
     * <li>LocalID</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMEndReleaseFields fields,
        FieldNameList fieldNames) throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMTrussGroup {
    /**
     * Gets the fields of this FEMTrussGroup object.
     *
     * @return FEMTrussGroup object fields
     */
    idempotent FEMTrussGroupFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMTrussGroup object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Displacement</li>
     * <li>GAPS</li>
     * <li>Group</li>
     * <li>IniStrain</li>
     * <li>Material</li>
     * <li>SectionArea</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMTrussGroupFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [FEMGroup] object refered to by the
     * Group field.
     *
     * @return Group interface
     */
    idempotent FEMGroup* getGroup() throws ServerError;

    /**
     * Gets the proxy to the [FEMMaterial] object refered to by the
     * Material field.
     *
     * @return Material interface
     */
    idempotent FEMMaterial* getMaterial() throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMInitialTemperature {
    /**
     * Gets the fields of this FEMInitialTemperature object.
     *
     * @return FEMInitialTemperature object fields
     */
    idempotent FEMInitialTemperatureFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMInitialTemperature object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Node</li>
     * <li>Temperature</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMInitialTemperatureFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * Node field.
     *
     * @return Node interface
     */
    idempotent FEMNode* getNode() throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMThermoIsoMaterials {
    /**
     * Gets the fields of this FEMThermoIsoMaterials object.
     *
     * @return FEMThermoIsoMaterials object fields
     */
    idempotent FEMThermoIsoMaterialsFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMThermoIsoMaterials object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Density</li>
     * <li>MaterialID</li>
     * <li>TREF</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMThermoIsoMaterialsFields fields,
        FieldNameList fieldNames) throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMThermoIsoData {
    /**
     * Gets the fields of this FEMThermoIsoData object.
     *
     * @return FEMThermoIsoData object fields
     */
    idempotent FEMThermoIsoDataFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMThermoIsoData object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>ALPHA</li>
     * <li>E</li>
     * <li>MaterialID</li>
     * <li>NU</li>
     * <li>RecordNmb</li>
     * <li>Theta</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMThermoIsoDataFields fields,
        FieldNameList fieldNames) throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMContactGroup3 {
    /**
     * Gets the fields of this FEMContactGroup3 object.
     *
     * @return FEMContactGroup3 object fields
     */
    idempotent FEMContactGroup3Fields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMContactGroup3 object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>ContGroupID</li>
     * <li>Depth</li>
     * <li>Description</li>
     * <li>Forces</li>
     * <li>Friction</li>
     * <li>IniPenetration</li>
     * <li>NodeToNode</li>
     * <li>Offset</li>
     * <li>PenetrAlgorithm</li>
     * <li>TBirth</li>
     * <li>TDeath</li>
     * <li>Tied</li>
     * <li>TiedOffset</li>
     * <li>Tolerance</li>
     * <li>Tractions</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMContactGroup3Fields fields,
        FieldNameList fieldNames) throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMNLElasticMaterials {
    /**
     * Gets the fields of this FEMNLElasticMaterials object.
     *
     * @return FEMNLElasticMaterials object fields
     */
    idempotent FEMNLElasticMaterialsFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMNLElasticMaterials object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Dcurve</li>
     * <li>Density</li>
     * <li>MaterialID</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMNLElasticMaterialsFields fields,
        FieldNameList fieldNames) throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMPlate {
    /**
     * Gets the fields of this FEMPlate object.
     *
     * @return FEMPlate object fields
     */
    idempotent FEMPlateFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMPlate object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Description</li>
     * <li>ElementID</li>
     * <li>Flex11</li>
     * <li>Flex12</li>
     * <li>Flex22</li>
     * <li>Group</li>
     * <li>MaterialID</li>
     * <li>Meps11</li>
     * <li>Meps12</li>
     * <li>Meps22</li>
     * <li>N1</li>
     * <li>N2</li>
     * <li>N3</li>
     * <li>RecordNmb</li>
     * <li>Save</li>
     * <li>TBirth</li>
     * <li>TDeath</li>
     * <li>Thick</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMPlateFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [FEMGroup] object refered to by the
     * Group field.
     *
     * @return Group interface
     */
    idempotent FEMGroup* getGroup() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * N1 field.
     *
     * @return N1 interface
     */
    idempotent FEMNode* getN1() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * N2 field.
     *
     * @return N2 interface
     */
    idempotent FEMNode* getN2() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * N3 field.
     *
     * @return N3 interface
     */
    idempotent FEMNode* getN3() throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMIsoBeam {
    /**
     * Gets the fields of this FEMIsoBeam object.
     *
     * @return FEMIsoBeam object fields
     */
    idempotent FEMIsoBeamFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMIsoBeam object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>AUX</li>
     * <li>Description</li>
     * <li>ElementID</li>
     * <li>Epaxl</li>
     * <li>Ephoop</li>
     * <li>Group</li>
     * <li>MaterialID</li>
     * <li>N1</li>
     * <li>N2</li>
     * <li>N3</li>
     * <li>N4</li>
     * <li>NodeAmount</li>
     * <li>RecordNmb</li>
     * <li>Save</li>
     * <li>SectionID</li>
     * <li>TBirth</li>
     * <li>TDeath</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMIsoBeamFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * AUX field.
     *
     * @return AUX interface
     */
    idempotent FEMNode* getAUX() throws ServerError;

    /**
     * Gets the proxy to the [FEMGroup] object refered to by the
     * Group field.
     *
     * @return Group interface
     */
    idempotent FEMGroup* getGroup() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * N1 field.
     *
     * @return N1 interface
     */
    idempotent FEMNode* getN1() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * N2 field.
     *
     * @return N2 interface
     */
    idempotent FEMNode* getN2() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * N3 field.
     *
     * @return N3 interface
     */
    idempotent FEMNode* getN3() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * N4 field.
     *
     * @return N4 interface
     */
    idempotent FEMNode* getN4() throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMAppliedConcentratedLoad {
    /**
     * Gets the fields of this FEMAppliedConcentratedLoad object.
     *
     * @return FEMAppliedConcentratedLoad object fields
     */
    idempotent FEMAppliedConcentratedLoadFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMAppliedConcentratedLoad object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>ArrivalTime</li>
     * <li>Description</li>
     * <li>Direction</li>
     * <li>Factor</li>
     * <li>NodeAux</li>
     * <li>NodeID</li>
     * <li>RecordNmb</li>
     * <li>TimeFunctionID</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMAppliedConcentratedLoadFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * NodeAux field.
     *
     * @return NodeAux interface
     */
    idempotent FEMNode* getNodeAux() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * NodeID field.
     *
     * @return NodeID interface
     */
    idempotent FEMNode* getNodeID() throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMTwoDSolidGroup {
    /**
     * Gets the fields of this FEMTwoDSolidGroup object.
     *
     * @return FEMTwoDSolidGroup object fields
     */
    idempotent FEMTwoDSolidGroupFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMTwoDSolidGroup object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>AuxNode</li>
     * <li>Displacement</li>
     * <li>Group</li>
     * <li>MaterialID</li>
     * <li>Result</li>
     * <li>Subtype</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMTwoDSolidGroupFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * AuxNode field.
     *
     * @return AuxNode interface
     */
    idempotent FEMNode* getAuxNode() throws ServerError;

    /**
     * Gets the proxy to the [FEMGroup] object refered to by the
     * Group field.
     *
     * @return Group interface
     */
    idempotent FEMGroup* getGroup() throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMGroup {
    /**
     * Gets the fields of this FEMGroup object.
     *
     * @return FEMGroup object fields
     */
    idempotent FEMGroupFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMGroup object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Description</li>
     * <li>GroupType</li>
     * <li>LocalID</li>
     * <li>Structure</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMGroupFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [Structure] object refered to by the
     * Structure field.
     *
     * @return Structure interface
     */
    idempotent Structure* getStructure() throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMProperties {
    /**
     * Gets the fields of this FEMProperties object.
     *
     * @return FEMProperties object fields
     */
    idempotent FEMPropertiesFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMProperties object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Description</li>
     * <li>PropertyID</li>
     * <li>PropertyType</li>
     * <li>Rupture</li>
     * <li>XC</li>
     * <li>XN</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMPropertiesFields fields,
        FieldNameList fieldNames) throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMThreeDSolidGroup {
    /**
     * Gets the fields of this FEMThreeDSolidGroup object.
     *
     * @return FEMThreeDSolidGroup object fields
     */
    idempotent FEMThreeDSolidGroupFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMThreeDSolidGroup object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Displacement</li>
     * <li>Group</li>
     * <li>MaterialID</li>
     * <li>Result</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMThreeDSolidGroupFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [FEMGroup] object refered to by the
     * Group field.
     *
     * @return Group interface
     */
    idempotent FEMGroup* getGroup() throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMThreeDSolid {
    /**
     * Gets the fields of this FEMThreeDSolid object.
     *
     * @return FEMThreeDSolid object fields
     */
    idempotent FEMThreeDSolidFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMThreeDSolid object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Description</li>
     * <li>ElementID</li>
     * <li>Group</li>
     * <li>MaterialID</li>
     * <li>Maxes</li>
     * <li>N1</li>
     * <li>N10</li>
     * <li>N11</li>
     * <li>N12</li>
     * <li>N13</li>
     * <li>N14</li>
     * <li>N15</li>
     * <li>N16</li>
     * <li>N17</li>
     * <li>N18</li>
     * <li>N19</li>
     * <li>N2</li>
     * <li>N20</li>
     * <li>N21</li>
     * <li>N22</li>
     * <li>N23</li>
     * <li>N24</li>
     * <li>N25</li>
     * <li>N26</li>
     * <li>N27</li>
     * <li>N3</li>
     * <li>N4</li>
     * <li>N5</li>
     * <li>N6</li>
     * <li>N7</li>
     * <li>N8</li>
     * <li>N9</li>
     * <li>NodeAmount</li>
     * <li>RecordNmb</li>
     * <li>Save</li>
     * <li>TBirth</li>
     * <li>TDeath</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMThreeDSolidFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [FEMGroup] object refered to by the
     * Group field.
     *
     * @return Group interface
     */
    idempotent FEMGroup* getGroup() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * N1 field.
     *
     * @return N1 interface
     */
    idempotent FEMNode* getN1() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * N10 field.
     *
     * @return N10 interface
     */
    idempotent FEMNode* getN10() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * N11 field.
     *
     * @return N11 interface
     */
    idempotent FEMNode* getN11() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * N12 field.
     *
     * @return N12 interface
     */
    idempotent FEMNode* getN12() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * N13 field.
     *
     * @return N13 interface
     */
    idempotent FEMNode* getN13() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * N14 field.
     *
     * @return N14 interface
     */
    idempotent FEMNode* getN14() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * N15 field.
     *
     * @return N15 interface
     */
    idempotent FEMNode* getN15() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * N16 field.
     *
     * @return N16 interface
     */
    idempotent FEMNode* getN16() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * N17 field.
     *
     * @return N17 interface
     */
    idempotent FEMNode* getN17() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * N18 field.
     *
     * @return N18 interface
     */
    idempotent FEMNode* getN18() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * N19 field.
     *
     * @return N19 interface
     */
    idempotent FEMNode* getN19() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * N2 field.
     *
     * @return N2 interface
     */
    idempotent FEMNode* getN2() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * N20 field.
     *
     * @return N20 interface
     */
    idempotent FEMNode* getN20() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * N21 field.
     *
     * @return N21 interface
     */
    idempotent FEMNode* getN21() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * N22 field.
     *
     * @return N22 interface
     */
    idempotent FEMNode* getN22() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * N23 field.
     *
     * @return N23 interface
     */
    idempotent FEMNode* getN23() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * N24 field.
     *
     * @return N24 interface
     */
    idempotent FEMNode* getN24() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * N25 field.
     *
     * @return N25 interface
     */
    idempotent FEMNode* getN25() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * N26 field.
     *
     * @return N26 interface
     */
    idempotent FEMNode* getN26() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * N27 field.
     *
     * @return N27 interface
     */
    idempotent FEMNode* getN27() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * N3 field.
     *
     * @return N3 interface
     */
    idempotent FEMNode* getN3() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * N4 field.
     *
     * @return N4 interface
     */
    idempotent FEMNode* getN4() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * N5 field.
     *
     * @return N5 interface
     */
    idempotent FEMNode* getN5() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * N6 field.
     *
     * @return N6 interface
     */
    idempotent FEMNode* getN6() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * N7 field.
     *
     * @return N7 interface
     */
    idempotent FEMNode* getN7() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * N8 field.
     *
     * @return N8 interface
     */
    idempotent FEMNode* getN8() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * N9 field.
     *
     * @return N9 interface
     */
    idempotent FEMNode* getN9() throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMSectionProp {
    /**
     * Gets the fields of this FEMSectionProp object.
     *
     * @return FEMSectionProp object fields
     */
    idempotent FEMSectionPropFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMSectionProp object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Area</li>
     * <li>Rinertia</li>
     * <li>Sarea</li>
     * <li>Section</li>
     * <li>Sinertia</li>
     * <li>Tarea</li>
     * <li>Tinertia</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMSectionPropFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [FEMCrossSection] object refered to by the
     * Section field.
     *
     * @return Section interface
     */
    idempotent FEMCrossSection* getSection() throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMElasticMaterial {
    /**
     * Gets the fields of this FEMElasticMaterial object.
     *
     * @return FEMElasticMaterial object fields
     */
    idempotent FEMElasticMaterialFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMElasticMaterial object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Alpha</li>
     * <li>Density</li>
     * <li>E</li>
     * <li>Material</li>
     * <li>NU</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMElasticMaterialFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [FEMMaterial] object refered to by the
     * Material field.
     *
     * @return Material interface
     */
    idempotent FEMMaterial* getMaterial() throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMPoints {
    /**
     * Gets the fields of this FEMPoints object.
     *
     * @return FEMPoints object fields
     */
    idempotent FEMPointsFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMPoints object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Description</li>
     * <li>PointID</li>
     * <li>SystemID</li>
     * <li>X</li>
     * <li>Y</li>
     * <li>Z</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMPointsFields fields,
        FieldNameList fieldNames) throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMThermoOrthMaterials {
    /**
     * Gets the fields of this FEMThermoOrthMaterials object.
     *
     * @return FEMThermoOrthMaterials object fields
     */
    idempotent FEMThermoOrthMaterialsFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMThermoOrthMaterials object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Density</li>
     * <li>MaterialID</li>
     * <li>TREF</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMThermoOrthMaterialsFields fields,
        FieldNameList fieldNames) throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMConstraints {
    /**
     * Gets the fields of this FEMConstraints object.
     *
     * @return FEMConstraints object fields
     */
    idempotent FEMConstraintsFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMConstraints object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>ConstraintID</li>
     * <li>Description</li>
     * <li>SlaveDOF</li>
     * <li>SlaveNode</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMConstraintsFields fields,
        FieldNameList fieldNames) throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMMCrigidities {
    /**
     * Gets the fields of this FEMMCrigidities object.
     *
     * @return FEMMCrigidities object fields
     */
    idempotent FEMMCrigiditiesFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMMCrigidities object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>AcurveType</li>
     * <li>Alpha</li>
     * <li>AxialCF</li>
     * <li>BcurveType</li>
     * <li>BendingCF</li>
     * <li>Beta</li>
     * <li>Density</li>
     * <li>ForceAxID</li>
     * <li>Hardening</li>
     * <li>MassArea</li>
     * <li>MassR</li>
     * <li>MassS</li>
     * <li>MassT</li>
     * <li>MomentRID</li>
     * <li>MomentSID</li>
     * <li>MomentTID</li>
     * <li>RigidityID</li>
     * <li>TcurveType</li>
     * <li>TorsionCF</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMMCrigiditiesFields fields,
        FieldNameList fieldNames) throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMSkeySysNode {
    /**
     * Gets the fields of this FEMSkeySysNode object.
     *
     * @return FEMSkeySysNode object fields
     */
    idempotent FEMSkeySysNodeFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMSkeySysNode object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Description</li>
     * <li>Node1</li>
     * <li>Node2</li>
     * <li>Node3</li>
     * <li>SkewSystemID</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMSkeySysNodeFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * Node1 field.
     *
     * @return Node1 interface
     */
    idempotent FEMNode* getNode1() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * Node2 field.
     *
     * @return Node2 interface
     */
    idempotent FEMNode* getNode2() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * Node3 field.
     *
     * @return Node3 interface
     */
    idempotent FEMNode* getNode3() throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMIsoBeamGroup {
    /**
     * Gets the fields of this FEMIsoBeamGroup object.
     *
     * @return FEMIsoBeamGroup object fields
     */
    idempotent FEMIsoBeamGroupFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMIsoBeamGroup object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Displacement</li>
     * <li>Group</li>
     * <li>IniStrain</li>
     * <li>MaterialID</li>
     * <li>Result</li>
     * <li>SectionID</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMIsoBeamGroupFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [FEMGroup] object refered to by the
     * Group field.
     *
     * @return Group interface
     */
    idempotent FEMGroup* getGroup() throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMShellDOF {
    /**
     * Gets the fields of this FEMShellDOF object.
     *
     * @return FEMShellDOF object fields
     */
    idempotent FEMShellDOFFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMShellDOF object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>DOFnumber</li>
     * <li>Node</li>
     * <li>VectorID</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMShellDOFFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * Node field.
     *
     * @return Node interface
     */
    idempotent FEMNode* getNode() throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMCrossSection {
    /**
     * Gets the fields of this FEMCrossSection object.
     *
     * @return FEMCrossSection object fields
     */
    idempotent FEMCrossSectionFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMCrossSection object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Description</li>
     * <li>SectionType</li>
     * <li>LocalID</li>
     * <li>Structure</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMCrossSectionFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [Structure] object refered to by the
     * Structure field.
     *
     * @return Structure interface
     */
    idempotent Structure* getStructure() throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMTwistMomentData {
    /**
     * Gets the fields of this FEMTwistMomentData object.
     *
     * @return FEMTwistMomentData object fields
     */
    idempotent FEMTwistMomentDataFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMTwistMomentData object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Moment</li>
     * <li>RecordNmb</li>
     * <li>Twist</li>
     * <li>TwistMomentID</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMTwistMomentDataFields fields,
        FieldNameList fieldNames) throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMShell {
    /**
     * Gets the fields of this FEMShell object.
     *
     * @return FEMShell object fields
     */
    idempotent FEMShellFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMShell object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Description</li>
     * <li>ElementID</li>
     * <li>Group</li>
     * <li>Material</li>
     * <li>N1</li>
     * <li>N2</li>
     * <li>N3</li>
     * <li>N4</li>
     * <li>N5</li>
     * <li>N6</li>
     * <li>N7</li>
     * <li>N8</li>
     * <li>N9</li>
     * <li>NodeAmount</li>
     * <li>RecordNmb</li>
     * <li>Save</li>
     * <li>T1</li>
     * <li>T2</li>
     * <li>T3</li>
     * <li>T4</li>
     * <li>T5</li>
     * <li>T6</li>
     * <li>T7</li>
     * <li>T8</li>
     * <li>T9</li>
     * <li>TBirth</li>
     * <li>TDeath</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMShellFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [FEMGroup] object refered to by the
     * Group field.
     *
     * @return Group interface
     */
    idempotent FEMGroup* getGroup() throws ServerError;

    /**
     * Gets the proxy to the [FEMMaterial] object refered to by the
     * Material field.
     *
     * @return Material interface
     */
    idempotent FEMMaterial* getMaterial() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * N1 field.
     *
     * @return N1 interface
     */
    idempotent FEMNode* getN1() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * N2 field.
     *
     * @return N2 interface
     */
    idempotent FEMNode* getN2() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * N3 field.
     *
     * @return N3 interface
     */
    idempotent FEMNode* getN3() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * N4 field.
     *
     * @return N4 interface
     */
    idempotent FEMNode* getN4() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * N5 field.
     *
     * @return N5 interface
     */
    idempotent FEMNode* getN5() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * N6 field.
     *
     * @return N6 interface
     */
    idempotent FEMNode* getN6() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * N7 field.
     *
     * @return N7 interface
     */
    idempotent FEMNode* getN7() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * N8 field.
     *
     * @return N8 interface
     */
    idempotent FEMNode* getN8() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * N9 field.
     *
     * @return N9 interface
     */
    idempotent FEMNode* getN9() throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMNTNContact {
    /**
     * Gets the fields of this FEMNTNContact object.
     *
     * @return FEMNTNContact object fields
     */
    idempotent FEMNTNContactFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMNTNContact object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>ContactorNode</li>
     * <li>ContGroupID</li>
     * <li>ContPair</li>
     * <li>PrintRes</li>
     * <li>RecordNmb</li>
     * <li>SaveRes</li>
     * <li>TargetNode</li>
     * <li>TargetNx</li>
     * <li>TargetNy</li>
     * <li>TargetNz</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMNTNContactFields fields,
        FieldNameList fieldNames) throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMShellLayer {
    /**
     * Gets the fields of this FEMShellLayer object.
     *
     * @return FEMShellLayer object fields
     */
    idempotent FEMShellLayerFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMShellLayer object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Group</li>
     * <li>LayerNumber</li>
     * <li>MaterialID</li>
     * <li>PThick</li>
     * <li>RecordNmb</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMShellLayerFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [FEMGroup] object refered to by the
     * Group field.
     *
     * @return Group interface
     */
    idempotent FEMGroup* getGroup() throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMSkewSysAngles {
    /**
     * Gets the fields of this FEMSkewSysAngles object.
     *
     * @return FEMSkewSysAngles object fields
     */
    idempotent FEMSkewSysAnglesFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMSkewSysAngles object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Description</li>
     * <li>PHI</li>
     * <li>SkewSystemID</li>
     * <li>THETA</li>
     * <li>XSI</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMSkewSysAnglesFields fields,
        FieldNameList fieldNames) throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMGroundMotionRecord {
    /**
     * Gets the fields of this FEMGroundMotionRecord object.
     *
     * @return FEMGroundMotionRecord object fields
     */
    idempotent FEMGroundMotionRecordFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMGroundMotionRecord object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Description</li>
     * <li>GMRecordID</li>
     * <li>GMRecordName</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMGroundMotionRecordFields fields,
        FieldNameList fieldNames) throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMGeneralGroup {
    /**
     * Gets the fields of this FEMGeneralGroup object.
     *
     * @return FEMGeneralGroup object fields
     */
    idempotent FEMGeneralGroupFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMGeneralGroup object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Group</li>
     * <li>MatrixSet</li>
     * <li>Result</li>
     * <li>SkewSystem</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMGeneralGroupFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [FEMGroup] object refered to by the
     * Group field.
     *
     * @return Group interface
     */
    idempotent FEMGroup* getGroup() throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMTwoDSolid {
    /**
     * Gets the fields of this FEMTwoDSolid object.
     *
     * @return FEMTwoDSolid object fields
     */
    idempotent FEMTwoDSolidFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMTwoDSolid object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Bet</li>
     * <li>Description</li>
     * <li>ElementID</li>
     * <li>Group</li>
     * <li>MaterialID</li>
     * <li>N1</li>
     * <li>N2</li>
     * <li>N3</li>
     * <li>N4</li>
     * <li>N5</li>
     * <li>N6</li>
     * <li>N7</li>
     * <li>N8</li>
     * <li>N9</li>
     * <li>NodeAmount</li>
     * <li>RecordNmb</li>
     * <li>Save</li>
     * <li>TBirth</li>
     * <li>TDeath</li>
     * <li>Thick</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMTwoDSolidFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [FEMGroup] object refered to by the
     * Group field.
     *
     * @return Group interface
     */
    idempotent FEMGroup* getGroup() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * N1 field.
     *
     * @return N1 interface
     */
    idempotent FEMNode* getN1() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * N2 field.
     *
     * @return N2 interface
     */
    idempotent FEMNode* getN2() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * N3 field.
     *
     * @return N3 interface
     */
    idempotent FEMNode* getN3() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * N4 field.
     *
     * @return N4 interface
     */
    idempotent FEMNode* getN4() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * N5 field.
     *
     * @return N5 interface
     */
    idempotent FEMNode* getN5() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * N6 field.
     *
     * @return N6 interface
     */
    idempotent FEMNode* getN6() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * N7 field.
     *
     * @return N7 interface
     */
    idempotent FEMNode* getN7() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * N8 field.
     *
     * @return N8 interface
     */
    idempotent FEMNode* getN8() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * N9 field.
     *
     * @return N9 interface
     */
    idempotent FEMNode* getN9() throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMAppliedTemperature {
    /**
     * Gets the fields of this FEMAppliedTemperature object.
     *
     * @return FEMAppliedTemperature object fields
     */
    idempotent FEMAppliedTemperatureFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMAppliedTemperature object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>ArrivalTime</li>
     * <li>Factor</li>
     * <li>Node</li>
     * <li>RecordNmbr</li>
     * <li>TimeFunctionID</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMAppliedTemperatureFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * Node field.
     *
     * @return Node interface
     */
    idempotent FEMNode* getNode() throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMMatrixSets {
    /**
     * Gets the fields of this FEMMatrixSets object.
     *
     * @return FEMMatrixSets object fields
     */
    idempotent FEMMatrixSetsFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMMatrixSets object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Damping</li>
     * <li>Description</li>
     * <li>Mass</li>
     * <li>MatrixSetID</li>
     * <li>Stiffness</li>
     * <li>Stress</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMMatrixSetsFields fields,
        FieldNameList fieldNames) throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMConstraintCoef {
    /**
     * Gets the fields of this FEMConstraintCoef object.
     *
     * @return FEMConstraintCoef object fields
     */
    idempotent FEMConstraintCoefFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMConstraintCoef object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Coefficient</li>
     * <li>ConstraintID</li>
     * <li>Description</li>
     * <li>MasterDOF</li>
     * <li>MasterNode</li>
     * <li>RecordNmb</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMConstraintCoefFields fields,
        FieldNameList fieldNames) throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMSectionBox {
    /**
     * Gets the fields of this FEMSectionBox object.
     *
     * @return FEMSectionBox object fields
     */
    idempotent FEMSectionBoxFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMSectionBox object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Height</li>
     * <li>SC</li>
     * <li>Section</li>
     * <li>SSarea</li>
     * <li>TC</li>
     * <li>Thick1</li>
     * <li>Thick2</li>
     * <li>Torfac</li>
     * <li>TSarea</li>
     * <li>Width</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMSectionBoxFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [FEMCrossSection] object refered to by the
     * Section field.
     *
     * @return Section interface
     */
    idempotent FEMCrossSection* getSection() throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMNKDisplForce {
    /**
     * Gets the fields of this FEMNKDisplForce object.
     *
     * @return FEMNKDisplForce object fields
     */
    idempotent FEMNKDisplForceFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMNKDisplForce object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Displacement</li>
     * <li>Force</li>
     * <li>PropertyID</li>
     * <li>RecordNmb</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMNKDisplForceFields fields,
        FieldNameList fieldNames) throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMPlasticStrainStress {
    /**
     * Gets the fields of this FEMPlasticStrainStress object.
     *
     * @return FEMPlasticStrainStress object fields
     */
    idempotent FEMPlasticStrainStressFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMPlasticStrainStress object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>MaterialID</li>
     * <li>RecordNumber</li>
     * <li>Strain</li>
     * <li>Stress</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMPlasticStrainStressFields fields,
        FieldNameList fieldNames) throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMShellAxesOrthoData {
    /**
     * Gets the fields of this FEMShellAxesOrthoData object.
     *
     * @return FEMShellAxesOrthoData object fields
     */
    idempotent FEMShellAxesOrthoDataFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMShellAxesOrthoData object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>AxOrthoID</li>
     * <li>ElementID</li>
     * <li>RecordNmb</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMShellAxesOrthoDataFields fields,
        FieldNameList fieldNames) throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMGeneralNode {
    /**
     * Gets the fields of this FEMGeneralNode object.
     *
     * @return FEMGeneralNode object fields
     */
    idempotent FEMGeneralNodeFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMGeneralNode object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>ElementID</li>
     * <li>Group</li>
     * <li>LocalNmb</li>
     * <li>Node</li>
     * <li>RecordNmb</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMGeneralNodeFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [FEMGroup] object refered to by the
     * Group field.
     *
     * @return Group interface
     */
    idempotent FEMGroup* getGroup() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * Node field.
     *
     * @return Node interface
     */
    idempotent FEMNode* getNode() throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMStrLines {
    /**
     * Gets the fields of this FEMStrLines object.
     *
     * @return FEMStrLines object fields
     */
    idempotent FEMStrLinesFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMStrLines object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>LineID</li>
     * <li>P1</li>
     * <li>P2</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMStrLinesFields fields,
        FieldNameList fieldNames) throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMContactSurface {
    /**
     * Gets the fields of this FEMContactSurface object.
     *
     * @return FEMContactSurface object fields
     */
    idempotent FEMContactSurfaceFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMContactSurface object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>ContGroupID</li>
     * <li>ContSegment</li>
     * <li>ContSurface</li>
     * <li>N1</li>
     * <li>N2</li>
     * <li>N3</li>
     * <li>N4</li>
     * <li>RecordNmb</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMContactSurfaceFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * N1 field.
     *
     * @return N1 interface
     */
    idempotent FEMNode* getN1() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * N2 field.
     *
     * @return N2 interface
     */
    idempotent FEMNode* getN2() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * N3 field.
     *
     * @return N3 interface
     */
    idempotent FEMNode* getN3() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * N4 field.
     *
     * @return N4 interface
     */
    idempotent FEMNode* getN4() throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMMCForceData {
    /**
     * Gets the fields of this FEMMCForceData object.
     *
     * @return FEMMCForceData object fields
     */
    idempotent FEMMCForceDataFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMMCForceData object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>CurvMomentID</li>
     * <li>Force</li>
     * <li>MomentSTID</li>
     * <li>RecordNmb</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMMCForceDataFields fields,
        FieldNameList fieldNames) throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMSpring {
    /**
     * Gets the fields of this FEMSpring object.
     *
     * @return FEMSpring object fields
     */
    idempotent FEMSpringFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMSpring object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>AX</li>
     * <li>AY</li>
     * <li>AZ</li>
     * <li>Description</li>
     * <li>ElementID</li>
     * <li>Group</li>
     * <li>ID1</li>
     * <li>ID2</li>
     * <li>N1</li>
     * <li>N2</li>
     * <li>PropertySet</li>
     * <li>RecordNmb</li>
     * <li>Save</li>
     * <li>TBirth</li>
     * <li>TDeath</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMSpringFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [FEMGroup] object refered to by the
     * Group field.
     *
     * @return Group interface
     */
    idempotent FEMGroup* getGroup() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * N1 field.
     *
     * @return N1 interface
     */
    idempotent FEMNode* getN1() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * N2 field.
     *
     * @return N2 interface
     */
    idempotent FEMNode* getN2() throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMSpringGroup {
    /**
     * Gets the fields of this FEMSpringGroup object.
     *
     * @return FEMSpringGroup object fields
     */
    idempotent FEMSpringGroupFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMSpringGroup object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Bolt</li>
     * <li>Group</li>
     * <li>Nonlinear</li>
     * <li>PropertySet</li>
     * <li>Result</li>
     * <li>SkewSystem</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMSpringGroupFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [FEMGroup] object refered to by the
     * Group field.
     *
     * @return Group interface
     */
    idempotent FEMGroup* getGroup() throws ServerError;
  };

  /**
   * 
   *
   */
  interface FEMShellGroup {
    /**
     * Gets the fields of this FEMShellGroup object.
     *
     * @return FEMShellGroup object fields
     */
    idempotent FEMShellGroupFields getFields() throws ServerError;

    /**
     * Updates the fields of this FEMShellGroup object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Displacement</li>
     * <li>Group</li>
     * <li>Material</li>
     * <li>NLayers</li>
     * <li>Result</li>
     * <li>SectionResult</li>
     * <li>StressReference</li>
     * <li>Thickness</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FEMShellGroupFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [FEMGroup] object refered to by the
     * Group field.
     *
     * @return Group interface
     */
    idempotent FEMGroup* getGroup() throws ServerError;

    /**
     * Gets the proxy to the [FEMMaterial] object refered to by the
     * Material field.
     *
     * @return Material interface
     */
    idempotent FEMMaterial* getMaterial() throws ServerError;
  };

  /**
   * * Data acquisition unit (e.g. Narada node).
 
   *
   */
  interface DaqUnit {
    /**
     * Gets the fields of this DaqUnit object.
     *
     * @return DaqUnit object fields
     */
    idempotent DaqUnitFields getFields() throws ServerError;

    /**
     * Updates the fields of this DaqUnit object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Model</li>
     * <li>Identifier</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(DaqUnitFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the IDs of the [DaqUnitChannel] child objects.
     *
     * The child objects refer to this object.
     *
     * @return list of [DaqUnitChannel] child object IDs
     */
    idempotent IdList getDaqUnitChannelChildIds() throws ServerError;
  };

  /**
   * * Data acquisition unit channel.
 
   *
   */
  interface DaqUnitChannel {
    /**
     * Gets the fields of this DaqUnitChannel object.
     *
     * @return DaqUnitChannel object fields
     */
    idempotent DaqUnitChannelFields getFields() throws ServerError;

    /**
     * Updates the fields of this DaqUnitChannel object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Unit</li>
     * <li>Number</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(DaqUnitChannelFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [DaqUnit] object refered to by the
     * Unit field.
     *
     * @return Unit interface
     */
    idempotent DaqUnit* getUnit() throws ServerError;

    /**
     * Gets the IDs of the [DaqUnitChannelData] child objects.
     *
     * The child objects refer to this object.
     *
     * @return list of [DaqUnitChannelData] child object IDs
     */
    idempotent IdList getDaqUnitChannelDataChildIds() throws ServerError;
  };

  /**
   * * Sensor.
 
   *
   */
  interface Sensor {
    /**
     * Gets the fields of this Sensor object.
     *
     * @return Sensor object fields
     */
    idempotent SensorFields getFields() throws ServerError;

    /**
     * Updates the fields of this Sensor object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Type</li>
     * <li>Model</li>
     * <li>Identifier</li>
     * <li>Description</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(SensorFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the IDs of the [SensorChannel] child objects.
     *
     * The child objects refer to this object.
     *
     * @return list of [SensorChannel] child object IDs
     */
    idempotent IdList getSensorChannelChildIds() throws ServerError;
  };

  /**
   * * Sensor channel.
 
   *
   */
  interface SensorChannel {
    /**
     * Gets the fields of this SensorChannel object.
     *
     * @return SensorChannel object fields
     */
    idempotent SensorChannelFields getFields() throws ServerError;

    /**
     * Updates the fields of this SensorChannel object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Sensor</li>
     * <li>Number</li>
     * <li>Description</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(SensorChannelFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [Sensor] object refered to by the
     * Sensor field.
     *
     * @return Sensor interface
     */
    idempotent Sensor* getSensor() throws ServerError;

    /**
     * Gets the IDs of the [SensorChannelConnection] child objects.
     *
     * The child objects refer to this object.
     *
     * @return list of [SensorChannelConnection] child object IDs
     */
    idempotent IdList getSensorChannelConnectionChildIds() throws ServerError;

    /**
     * Gets the IDs of the [SensorChannelData] child objects.
     *
     * The child objects refer to this object.
     *
     * @return list of [SensorChannelData] child object IDs
     */
    idempotent IdList getSensorChannelDataChildIds() throws ServerError;
  };

  /**
   * * Sensor channel connection.
 *
 * Defines the connection between a sensor channel and a DAQ unit
 * channel, the location of the sensor, and the duration of the
 * connection, as well as the data conversion coefficients.  This
 * allows to describe an instrumentation setup.  If the setup changes,
 * the corresponding connections must be severed, and new connections
 * created.
 *
 * Note that multiple channels of a single sensor may duplicate the
 * sensor location information, but otherwise the database model
 * becomes more complicated.
 *
 * Currently a linear mapping between the raw DAQ channel data and the
 * sensor channel data is implemented:
 *
 *   value = C0 + C1*raw;
 *
 * This can be easily extended to higher order polynomials in the future.
 * For custom conversions, the coefficients can be left at 0.0.
 
   *
   */
  interface SensorChannelConnection {
    /**
     * Gets the fields of this SensorChannelConnection object.
     *
     * @return SensorChannelConnection object fields
     */
    idempotent SensorChannelConnectionFields getFields() throws ServerError;

    /**
     * Updates the fields of this SensorChannelConnection object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>SensorChannel</li>
     * <li>DaqUnitChannel</li>
     * <li>Location</li>
     * <li>Component</li>
     * <li>OrientNode</li>
     * <li>Created</li>
     * <li>Severed</li>
     * <li>NotificationCategory</li>
     * <li>UpdateIntervalMax</li>
     * <li>C0</li>
     * <li>C1</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(SensorChannelConnectionFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [SensorChannel] object refered to by the
     * SensorChannel field.
     *
     * @return SensorChannel interface
     */
    idempotent SensorChannel* getSensorChannel() throws ServerError;

    /**
     * Gets the proxy to the [DaqUnitChannel] object refered to by the
     * DaqUnitChannel field.
     *
     * @return DaqUnitChannel interface
     */
    idempotent DaqUnitChannel* getDaqUnitChannel() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * Location field.
     *
     * @return Location interface
     */
    idempotent FEMNode* getLocation() throws ServerError;

    /**
     * Gets the proxy to the [StructureComponent] object refered to by the
     * Component field.
     *
     * @return Component interface
     */
    idempotent StructureComponent* getComponent() throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * OrientNode field.
     *
     * @return OrientNode interface
     */
    idempotent FEMNode* getOrientNode() throws ServerError;

    /**
     * Gets the proxy to the [NotificationCategory] object refered to by the
     * NotificationCategory field.
     *
     * @return NotificationCategory interface
     */
    idempotent NotificationCategory* getNotificationCategory() throws ServerError;
  };

  /**
   * Fixed camera (or webcam). 
   *
   */
  interface FixedCamera {
    /**
     * Gets the fields of this FixedCamera object.
     *
     * @return FixedCamera object fields
     */
    idempotent FixedCameraFields getFields() throws ServerError;

    /**
     * Updates the fields of this FixedCamera object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Node</li>
     * <li>Description</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FixedCameraFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [FEMNode] object refered to by the
     * Node field.
     *
     * @return Node interface
     */
    idempotent FEMNode* getNode() throws ServerError;

    /**
     * Adds a Photos file.
     *
     * Use the returned file ID to get a writer interface
     * to send the file contents
     * to the server.
     *
     * @param info file information (the size is ignored)
     * @return file ID
     * @see getPhotosFileWriter()
     */
    long addPhotosFileInfo(FileInfo info) throws ServerError;

    /**
     * Deletes a Photos file if it exists.
     *
     * @param id  file ID
     */
    idempotent void rmPhotosFile(long id) throws ServerError;

    /**
     * Writes a block of data to a Photos file.
     *
     * @param id      file ID
     * @param offset  starting point of the read (file pointer offset)
     * @param data    data to write
     */
    idempotent void writePhotosFile(long id, long offset, ByteSeq data) throws ServerError;

    /**
     * Gets information on a Photos file.
     *
     * @param id file ID
     * @return file information (empty if the file does not exist)
     */
    idempotent FileInfo getPhotosFileInfo(long id) throws ServerError;

    /**
     * Reads a block of data from a Photos file.
     *
     * This method may return less than the requested number of bytes
     * if the end of the file is reached.
     *
     * @param id      file ID
     * @param offset  starting point of the read (file pointer offset)
     * @param count   number of bytes to read
     */
    idempotent ByteSeq readPhotosFile(long id, long offset, int count) throws ServerError;

    /**
     * Gets the Photos file info list for the given time range.
     *
     * @param tStart  start of time range \[s]
     * @param tStop   end of time range \[s]
     * @return file information list
     */
    idempotent FileInfoList getPhotosFileInfoList(double tStart, double tStop);
  };

  /**
   * Detailed info of a bridge structure. 
   *
   */
  interface BridgeDetails {
    /**
     * Gets the fields of this BridgeDetails object.
     *
     * @return BridgeDetails object fields
     */
    idempotent BridgeDetailsFields getFields() throws ServerError;

    /**
     * Updates the fields of this BridgeDetails object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Structure</li>
     * <li>LastMajorRehab</li>
     * <li>RampsAttached</li>
     * <li>MainspanMaterial</li>
     * <li>LongestSpanLength</li>
     * <li>BridgeLength</li>
     * <li>OutToOutWidth</li>
     * <li>BridgeDeckArea</li>
     * <li>MedianWidth</li>
     * <li>AbutmentType</li>
     * <li>AbutmentHeight</li>
     * <li>BridgeCoordSystem</li>
     * <li>InspFreq</li>
     * <li>ScourEvl</li>
     * <li>NumPins</li>
     * <li>SuperStructureDesignType</li>
     * <li>SaltUsageLevel</li>
     * <li>SnowAccumulation</li>
     * <li>ClimateGroup</li>
     * <li>FuncClass</li>
     * <li>InspKey</li>
     * <li>ElementDesignType</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(BridgeDetailsFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [Structure] object refered to by the
     * Structure field.
     *
     * @return Structure interface
     */
    idempotent Structure* getStructure() throws ServerError;

    /**
     * Gets the proxy to the [FEMCoordSystem] object refered to by the
     * BridgeCoordSystem field.
     *
     * @return BridgeCoordSystem interface
     */
    idempotent FEMCoordSystem* getBridgeCoordSystem() throws ServerError;
  };

  /**
   * Road that a bridge carries 
   *
   */
  interface FacilityRoad {
    /**
     * Gets the fields of this FacilityRoad object.
     *
     * @return FacilityRoad object fields
     */
    idempotent FacilityRoadFields getFields() throws ServerError;

    /**
     * Updates the fields of this FacilityRoad object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Road</li>
     * <li>Structure</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FacilityRoadFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [Road] object refered to by the
     * Road field.
     *
     * @return Road interface
     */
    idempotent Road* getRoad() throws ServerError;

    /**
     * Gets the proxy to the [Structure] object refered to by the
     * Structure field.
     *
     * @return Structure interface
     */
    idempotent Structure* getStructure() throws ServerError;
  };

  /**
   * Railway track that a bridge carries. 
   *
   */
  interface FacilityRailway {
    /**
     * Gets the fields of this FacilityRailway object.
     *
     * @return FacilityRailway object fields
     */
    idempotent FacilityRailwayFields getFields() throws ServerError;

    /**
     * Updates the fields of this FacilityRailway object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Railway</li>
     * <li>Structure</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FacilityRailwayFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [Railway] object refered to by the
     * Railway field.
     *
     * @return Railway interface
     */
    idempotent Railway* getRailway() throws ServerError;

    /**
     * Gets the proxy to the [Structure] object refered to by the
     * Structure field.
     *
     * @return Structure interface
     */
    idempotent Structure* getStructure() throws ServerError;
  };

  /**
   * Road that a bridge crosses 
   *
   */
  interface FeatureRoad {
    /**
     * Gets the fields of this FeatureRoad object.
     *
     * @return FeatureRoad object fields
     */
    idempotent FeatureRoadFields getFields() throws ServerError;

    /**
     * Updates the fields of this FeatureRoad object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Road</li>
     * <li>Structure</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FeatureRoadFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [Road] object refered to by the
     * Road field.
     *
     * @return Road interface
     */
    idempotent Road* getRoad() throws ServerError;

    /**
     * Gets the proxy to the [Structure] object refered to by the
     * Structure field.
     *
     * @return Structure interface
     */
    idempotent Structure* getStructure() throws ServerError;
  };

  /**
   * Railway track that a bridge crosses 
   *
   */
  interface FeatureRailway {
    /**
     * Gets the fields of this FeatureRailway object.
     *
     * @return FeatureRailway object fields
     */
    idempotent FeatureRailwayFields getFields() throws ServerError;

    /**
     * Updates the fields of this FeatureRailway object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Railway</li>
     * <li>Structure</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FeatureRailwayFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [Railway] object refered to by the
     * Railway field.
     *
     * @return Railway interface
     */
    idempotent Railway* getRailway() throws ServerError;

    /**
     * Gets the proxy to the [Structure] object refered to by the
     * Structure field.
     *
     * @return Structure interface
     */
    idempotent Structure* getStructure() throws ServerError;
  };

  /**
   * River that a bridge crosses 
   *
   */
  interface FeatureRiver {
    /**
     * Gets the fields of this FeatureRiver object.
     *
     * @return FeatureRiver object fields
     */
    idempotent FeatureRiverFields getFields() throws ServerError;

    /**
     * Updates the fields of this FeatureRiver object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>River</li>
     * <li>Structure</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(FeatureRiverFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [River] object refered to by the
     * River field.
     *
     * @return River interface
     */
    idempotent River* getRiver() throws ServerError;

    /**
     * Gets the proxy to the [Structure] object refered to by the
     * Structure field.
     *
     * @return Structure interface
     */
    idempotent Structure* getStructure() throws ServerError;
  };

  /**
   * Road. 
   *
   */
  interface Road {
    /**
     * Gets the fields of this Road object.
     *
     * @return Road object fields
     */
    idempotent RoadFields getFields() throws ServerError;

    /**
     * Updates the fields of this Road object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Name</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(RoadFields fields,
        FieldNameList fieldNames) throws ServerError;
  };

  /**
   * Railway. 
   *
   */
  interface Railway {
    /**
     * Gets the fields of this Railway object.
     *
     * @return Railway object fields
     */
    idempotent RailwayFields getFields() throws ServerError;

    /**
     * Updates the fields of this Railway object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Name</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(RailwayFields fields,
        FieldNameList fieldNames) throws ServerError;
  };

  /**
   * River. 
   *
   */
  interface River {
    /**
     * Gets the fields of this River object.
     *
     * @return River object fields
     */
    idempotent RiverFields getFields() throws ServerError;

    /**
     * Updates the fields of this River object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Name</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(RiverFields fields,
        FieldNameList fieldNames) throws ServerError;
  };

  /**
   * Detailed information regarding bridge inspections. 
   *
   */
  interface BridgeInspection {
    /**
     * Gets the fields of this BridgeInspection object.
     *
     * @return BridgeInspection object fields
     */
    idempotent BridgeInspectionFields getFields() throws ServerError;

    /**
     * Updates the fields of this BridgeInspection object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>AssessmentDate</li>
     * <li>Inspector</li>
     * <li>InspectionAgency</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(BridgeInspectionFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [Inspector] object refered to by the
     * Inspector field.
     *
     * @return Inspector interface
     */
    idempotent Inspector* getInspector() throws ServerError;

    /**
     * Gets the proxy to the [InspectionAgency] object refered to by the
     * InspectionAgency field.
     *
     * @return InspectionAgency interface
     */
    idempotent InspectionAgency* getInspectionAgency() throws ServerError;
  };

  /**
   * Inspector. 
   *
   */
  interface Inspector {
    /**
     * Gets the fields of this Inspector object.
     *
     * @return Inspector object fields
     */
    idempotent InspectorFields getFields() throws ServerError;

    /**
     * Updates the fields of this Inspector object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Name</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(InspectorFields fields,
        FieldNameList fieldNames) throws ServerError;
  };

  /**
   * Inspection agency. 
   *
   */
  interface InspectionAgency {
    /**
     * Gets the fields of this InspectionAgency object.
     *
     * @return InspectionAgency object fields
     */
    idempotent InspectionAgencyFields getFields() throws ServerError;

    /**
     * Updates the fields of this InspectionAgency object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Name</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(InspectionAgencyFields fields,
        FieldNameList fieldNames) throws ServerError;
  };

  /**
   * Structure assessment. 
   *
   */
  interface StructureAssessment {
    /**
     * Gets the fields of this StructureAssessment object.
     *
     * @return StructureAssessment object fields
     */
    idempotent StructureAssessmentFields getFields() throws ServerError;

    /**
     * Updates the fields of this StructureAssessment object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Structure</li>
     * <li>AssessmentDate</li>
     * <li>TotalReliability</li>
     * <li>TotalRisk</li>
     * <li>TotalRating</li>
     * <li>BridgeInspection</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(StructureAssessmentFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [Structure] object refered to by the
     * Structure field.
     *
     * @return Structure interface
     */
    idempotent Structure* getStructure() throws ServerError;

    /**
     * Gets the proxy to the [BridgeInspection] object refered to by the
     * BridgeInspection field.
     *
     * @return BridgeInspection interface
     */
    idempotent BridgeInspection* getBridgeInspection() throws ServerError;

    /**
     * Adds a InspectionReport file.
     *
     * Use the returned file ID to get a writer interface
     * to send the file contents
     * to the server.
     *
     * @param info file information (the size is ignored)
     * @return file ID
     * @see getInspectionReportFileWriter()
     */
    long addInspectionReportFileInfo(FileInfo info) throws ServerError;

    /**
     * Deletes a InspectionReport file if it exists.
     *
     * @param id  file ID
     */
    idempotent void rmInspectionReportFile(long id) throws ServerError;

    /**
     * Writes a block of data to a InspectionReport file.
     *
     * @param id      file ID
     * @param offset  starting point of the read (file pointer offset)
     * @param data    data to write
     */
    idempotent void writeInspectionReportFile(long id, long offset, ByteSeq data) throws ServerError;

    /**
     * Gets information on a InspectionReport file.
     *
     * @param id file ID
     * @return file information (empty if the file does not exist)
     */
    idempotent FileInfo getInspectionReportFileInfo(long id) throws ServerError;

    /**
     * Reads a block of data from a InspectionReport file.
     *
     * This method may return less than the requested number of bytes
     * if the end of the file is reached.
     *
     * @param id      file ID
     * @param offset  starting point of the read (file pointer offset)
     * @param count   number of bytes to read
     */
    idempotent ByteSeq readInspectionReportFile(long id, long offset, int count) throws ServerError;

    /**
     * Gets the InspectionReport file info list for the given time range.
     *
     * @param tStart  start of time range \[s]
     * @param tStop   end of time range \[s]
     * @return file information list
     */
    idempotent FileInfoList getInspectionReportFileInfoList(double tStart, double tStop);
  };

  /**
   * Structure retrofit. 
   *
   */
  interface StructureRetrofit {
    /**
     * Gets the fields of this StructureRetrofit object.
     *
     * @return StructureRetrofit object fields
     */
    idempotent StructureRetrofitFields getFields() throws ServerError;

    /**
     * Updates the fields of this StructureRetrofit object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Structure</li>
     * <li>Date</li>
     * <li>Summary</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(StructureRetrofitFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [Structure] object refered to by the
     * Structure field.
     *
     * @return Structure interface
     */
    idempotent Structure* getStructure() throws ServerError;
  };

  /**
   * PONTIS element. 
   *
   */
  interface PontisElement {
    /**
     * Gets the fields of this PontisElement object.
     *
     * @return PontisElement object fields
     */
    idempotent PontisElementFields getFields() throws ServerError;

    /**
     * Updates the fields of this PontisElement object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Description</li>
     * <li>Category</li>
     * <li>Units</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(PontisElementFields fields,
        FieldNameList fieldNames) throws ServerError;
  };

  /**
   * Structure components. 
   *
   */
  interface StructureComponent {
    /**
     * Gets the fields of this StructureComponent object.
     *
     * @return StructureComponent object fields
     */
    idempotent StructureComponentFields getFields() throws ServerError;

    /**
     * Updates the fields of this StructureComponent object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Structure</li>
     * <li>Type</li>
     * <li>Description</li>
     * <li>PontisElement</li>
     * <li>Material</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(StructureComponentFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [Structure] object refered to by the
     * Structure field.
     *
     * @return Structure interface
     */
    idempotent Structure* getStructure() throws ServerError;

    /**
     * Gets the proxy to the [PontisElement] object refered to by the
     * PontisElement field.
     *
     * @return PontisElement interface
     */
    idempotent PontisElement* getPontisElement() throws ServerError;

    /**
     * Gets the IDs of the [ComponentInspElement] child objects.
     *
     * The child objects refer to this object.
     *
     * @return list of [ComponentInspElement] child object IDs
     */
    idempotent IdList getComponentInspElementChildIds() throws ServerError;

    /**
     * Gets the IDs of the [StructureComponentGroups] child objects.
     *
     * The child objects refer to this object.
     *
     * @return list of [StructureComponentGroups] child object IDs
     */
    idempotent IdList getStructureComponentGroupsChildIds() throws ServerError;

    /**
     * Gets the IDs of the [StructureComponentReliability] child objects.
     *
     * The child objects refer to this object.
     *
     * @return list of [StructureComponentReliability] child object IDs
     */
    idempotent IdList getStructureComponentReliabilityChildIds() throws ServerError;

    /**
     * Gets the IDs of the [StructureComponentAssessment] child objects.
     *
     * The child objects refer to this object.
     *
     * @return list of [StructureComponentAssessment] child object IDs
     */
    idempotent IdList getStructureComponentAssessmentChildIds() throws ServerError;

    /**
     * Gets the IDs of the [StructureComponentRating] child objects.
     *
     * The child objects refer to this object.
     *
     * @return list of [StructureComponentRating] child object IDs
     */
    idempotent IdList getStructureComponentRatingChildIds() throws ServerError;

    /**
     * Gets the IDs of the [StructureComponentRepairOption] child objects.
     *
     * The child objects refer to this object.
     *
     * @return list of [StructureComponentRepairOption] child object IDs
     */
    idempotent IdList getStructureComponentRepairOptionChildIds() throws ServerError;

    /**
     * Gets the IDs of the [StructureComponentRepair] child objects.
     *
     * The child objects refer to this object.
     *
     * @return list of [StructureComponentRepair] child object IDs
     */
    idempotent IdList getStructureComponentRepairChildIds() throws ServerError;

    /**
     * Gets the IDs of the [CompRepairFinalCond] child objects.
     *
     * The child objects refer to this object.
     *
     * @return list of [CompRepairFinalCond] child object IDs
     */
    idempotent IdList getCompRepairFinalCondChildIds() throws ServerError;

    /**
     * Gets the IDs of the [CompRepairTimelineMatrix] child objects.
     *
     * The child objects refer to this object.
     *
     * @return list of [CompRepairTimelineMatrix] child object IDs
     */
    idempotent IdList getCompRepairTimelineMatrixChildIds() throws ServerError;

    /**
     * Gets the IDs of the [CompEnvBurdenMatrix] child objects.
     *
     * The child objects refer to this object.
     *
     * @return list of [CompEnvBurdenMatrix] child object IDs
     */
    idempotent IdList getCompEnvBurdenMatrixChildIds() throws ServerError;
  };

  /**
   * Component inspection elements. 
   *
   */
  interface ComponentInspElement {
    /**
     * Gets the fields of this ComponentInspElement object.
     *
     * @return ComponentInspElement object fields
     */
    idempotent ComponentInspElementFields getFields() throws ServerError;

    /**
     * Updates the fields of this ComponentInspElement object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>StructureComponent</li>
     * <li>Type</li>
     * <li>Description</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(ComponentInspElementFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [StructureComponent] object refered to by the
     * StructureComponent field.
     *
     * @return StructureComponent interface
     */
    idempotent StructureComponent* getStructureComponent() throws ServerError;

    /**
     * Gets the IDs of the [ComponentInspElementAssessment] child objects.
     *
     * The child objects refer to this object.
     *
     * @return list of [ComponentInspElementAssessment] child object IDs
     */
    idempotent IdList getComponentInspElementAssessmentChildIds() throws ServerError;
  };

  /**
   * Component FEM Groups. Links one or more FEM groups to a component. 
   *
   */
  interface StructureComponentGroups {
    /**
     * Gets the fields of this StructureComponentGroups object.
     *
     * @return StructureComponentGroups object fields
     */
    idempotent StructureComponentGroupsFields getFields() throws ServerError;

    /**
     * Updates the fields of this StructureComponentGroups object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Component</li>
     * <li>FEMGroup</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(StructureComponentGroupsFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [StructureComponent] object refered to by the
     * Component field.
     *
     * @return Component interface
     */
    idempotent StructureComponent* getComponent() throws ServerError;

    /**
     * Gets the proxy to the [FEMGroup] object refered to by the
     * FEMGroup field.
     *
     * @return FEMGroup interface
     */
    idempotent FEMGroup* getFEMGroup() throws ServerError;
  };

  /**
   * Structure component reliability. 
   *
   */
  interface StructureComponentReliability {
    /**
     * Gets the fields of this StructureComponentReliability object.
     *
     * @return StructureComponentReliability object fields
     */
    idempotent StructureComponentReliabilityFields getFields() throws ServerError;

    /**
     * Updates the fields of this StructureComponentReliability object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Component</li>
     * <li>ComputeDate</li>
     * <li>SensorMean</li>
     * <li>SensorCov</li>
     * <li>ComputeDLMean</li>
     * <li>ComputeDLCov</li>
     * <li>ComputeLLMean</li>
     * <li>ComputeLLCov</li>
     * <li>ComputeTempMean</li>
     * <li>ComputeTempCov</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(StructureComponentReliabilityFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [StructureComponent] object refered to by the
     * Component field.
     *
     * @return Component interface
     */
    idempotent StructureComponent* getComponent() throws ServerError;
  };

  /**
   * Structure component assessment. 
   *
   */
  interface StructureComponentAssessment {
    /**
     * Gets the fields of this StructureComponentAssessment object.
     *
     * @return StructureComponentAssessment object fields
     */
    idempotent StructureComponentAssessmentFields getFields() throws ServerError;

    /**
     * Updates the fields of this StructureComponentAssessment object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Component</li>
     * <li>AssessmentDate</li>
     * <li>Reliability</li>
     * <li>Risk</li>
     * <li>Rating</li>
     * <li>BridgeInspection</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(StructureComponentAssessmentFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [StructureComponent] object refered to by the
     * Component field.
     *
     * @return Component interface
     */
    idempotent StructureComponent* getComponent() throws ServerError;

    /**
     * Gets the proxy to the [BridgeInspection] object refered to by the
     * BridgeInspection field.
     *
     * @return BridgeInspection interface
     */
    idempotent BridgeInspection* getBridgeInspection() throws ServerError;
  };

  /**
   * Component rating. 
   *
   */
  interface StructureComponentRating {
    /**
     * Gets the fields of this StructureComponentRating object.
     *
     * @return StructureComponentRating object fields
     */
    idempotent StructureComponentRatingFields getFields() throws ServerError;

    /**
     * Updates the fields of this StructureComponentRating object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Component</li>
     * <li>AssessmentDate</li>
     * <li>UltimateLimit</li>
     * <li>AvgRatingLimit</li>
     * <li>OptmObjective</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(StructureComponentRatingFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [StructureComponent] object refered to by the
     * Component field.
     *
     * @return Component interface
     */
    idempotent StructureComponent* getComponent() throws ServerError;
  };

  /**
   * Structure component repair option. 
   *
   */
  interface StructureComponentRepairOption {
    /**
     * Gets the fields of this StructureComponentRepairOption object.
     *
     * @return StructureComponentRepairOption object fields
     */
    idempotent StructureComponentRepairOptionFields getFields() throws ServerError;

    /**
     * Updates the fields of this StructureComponentRepairOption object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Component</li>
     * <li>AssessmentDate</li>
     * <li>ComponentRepairOption</li>
     * <li>RepairDesc</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(StructureComponentRepairOptionFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [StructureComponent] object refered to by the
     * Component field.
     *
     * @return Component interface
     */
    idempotent StructureComponent* getComponent() throws ServerError;
  };

  /**
   * Average traffic information on structure. 
   *
   */
  interface StructureTraffic {
    /**
     * Gets the fields of this StructureTraffic object.
     *
     * @return StructureTraffic object fields
     */
    idempotent StructureTrafficFields getFields() throws ServerError;

    /**
     * Updates the fields of this StructureTraffic object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Structure</li>
     * <li>AssessmentDate</li>
     * <li>AADT</li>
     * <li>AADTT</li>
     * <li>TrafficChange</li>
     * <li>DiscountRate</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(StructureTrafficFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [Structure] object refered to by the
     * Structure field.
     *
     * @return Structure interface
     */
    idempotent Structure* getStructure() throws ServerError;
  };

  /**
   * Structure component repairs. 
   *
   */
  interface StructureComponentRepair {
    /**
     * Gets the fields of this StructureComponentRepair object.
     *
     * @return StructureComponentRepair object fields
     */
    idempotent StructureComponentRepairFields getFields() throws ServerError;

    /**
     * Updates the fields of this StructureComponentRepair object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Component</li>
     * <li>AssessmentDate</li>
     * <li>ComponentRepairOption</li>
     * <li>RepairDays</li>
     * <li>EconomicCost</li>
     * <li>Availability</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(StructureComponentRepairFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [StructureComponent] object refered to by the
     * Component field.
     *
     * @return Component interface
     */
    idempotent StructureComponent* getComponent() throws ServerError;
  };

  /**
   * Component inspection element assessment. 
   *
   */
  interface ComponentInspElementAssessment {
    /**
     * Gets the fields of this ComponentInspElementAssessment object.
     *
     * @return ComponentInspElementAssessment object fields
     */
    idempotent ComponentInspElementAssessmentFields getFields() throws ServerError;

    /**
     * Updates the fields of this ComponentInspElementAssessment object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>InspElement</li>
     * <li>BridgeInspection</li>
     * <li>Rating</li>
     * <li>Notes</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(ComponentInspElementAssessmentFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [ComponentInspElement] object refered to by the
     * InspElement field.
     *
     * @return InspElement interface
     */
    idempotent ComponentInspElement* getInspElement() throws ServerError;

    /**
     * Gets the proxy to the [BridgeInspection] object refered to by the
     * BridgeInspection field.
     *
     * @return BridgeInspection interface
     */
    idempotent BridgeInspection* getBridgeInspection() throws ServerError;
  };

  /**
   * Multimedia captured during inspection routines. 
   *
   */
  interface InspectionMultimedia {
    /**
     * Gets the fields of this InspectionMultimedia object.
     *
     * @return InspectionMultimedia object fields
     */
    idempotent InspectionMultimediaFields getFields() throws ServerError;

    /**
     * Updates the fields of this InspectionMultimedia object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>BridgeInspection</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(InspectionMultimediaFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [BridgeInspection] object refered to by the
     * BridgeInspection field.
     *
     * @return BridgeInspection interface
     */
    idempotent BridgeInspection* getBridgeInspection() throws ServerError;

    /**
     * Adds a MultimediaObject file.
     *
     * Use the returned file ID to get a writer interface
     * to send the file contents
     * to the server.
     *
     * @param info file information (the size is ignored)
     * @return file ID
     * @see getMultimediaObjectFileWriter()
     */
    long addMultimediaObjectFileInfo(FileInfo info) throws ServerError;

    /**
     * Deletes a MultimediaObject file if it exists.
     *
     * @param id  file ID
     */
    idempotent void rmMultimediaObjectFile(long id) throws ServerError;

    /**
     * Writes a block of data to a MultimediaObject file.
     *
     * @param id      file ID
     * @param offset  starting point of the read (file pointer offset)
     * @param data    data to write
     */
    idempotent void writeMultimediaObjectFile(long id, long offset, ByteSeq data) throws ServerError;

    /**
     * Gets information on a MultimediaObject file.
     *
     * @param id file ID
     * @return file information (empty if the file does not exist)
     */
    idempotent FileInfo getMultimediaObjectFileInfo(long id) throws ServerError;

    /**
     * Reads a block of data from a MultimediaObject file.
     *
     * This method may return less than the requested number of bytes
     * if the end of the file is reached.
     *
     * @param id      file ID
     * @param offset  starting point of the read (file pointer offset)
     * @param count   number of bytes to read
     */
    idempotent ByteSeq readMultimediaObjectFile(long id, long offset, int count) throws ServerError;

    /**
     * Gets the MultimediaObject file info list for the given time range.
     *
     * @param tStart  start of time range \[s]
     * @param tStop   end of time range \[s]
     * @return file information list
     */
    idempotent FileInfoList getMultimediaObjectFileInfoList(double tStart, double tStop);
  };

  /**
   * Inspection multimedia associated with the bridge. 
   *
   */
  interface BridgeInspectionMultimedia {
    /**
     * Gets the fields of this BridgeInspectionMultimedia object.
     *
     * @return BridgeInspectionMultimedia object fields
     */
    idempotent BridgeInspectionMultimediaFields getFields() throws ServerError;

    /**
     * Updates the fields of this BridgeInspectionMultimedia object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Structure</li>
     * <li>InspectionMultimedia</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(BridgeInspectionMultimediaFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [Structure] object refered to by the
     * Structure field.
     *
     * @return Structure interface
     */
    idempotent Structure* getStructure() throws ServerError;

    /**
     * Gets the proxy to the [InspectionMultimedia] object refered to by the
     * InspectionMultimedia field.
     *
     * @return InspectionMultimedia interface
     */
    idempotent InspectionMultimedia* getInspectionMultimedia() throws ServerError;
  };

  /**
   * Inspection multimedia associated with the components 
   *
   */
  interface ComponentInspectionMultimedia {
    /**
     * Gets the fields of this ComponentInspectionMultimedia object.
     *
     * @return ComponentInspectionMultimedia object fields
     */
    idempotent ComponentInspectionMultimediaFields getFields() throws ServerError;

    /**
     * Updates the fields of this ComponentInspectionMultimedia object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Component</li>
     * <li>InspectionMultimedia</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(ComponentInspectionMultimediaFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [StructureComponent] object refered to by the
     * Component field.
     *
     * @return Component interface
     */
    idempotent StructureComponent* getComponent() throws ServerError;

    /**
     * Gets the proxy to the [InspectionMultimedia] object refered to by the
     * InspectionMultimedia field.
     *
     * @return InspectionMultimedia interface
     */
    idempotent InspectionMultimedia* getInspectionMultimedia() throws ServerError;
  };

  /**
   * Inspection multimedia associated with the element 
   *
   */
  interface ElementInspectionMultimedia {
    /**
     * Gets the fields of this ElementInspectionMultimedia object.
     *
     * @return ElementInspectionMultimedia object fields
     */
    idempotent ElementInspectionMultimediaFields getFields() throws ServerError;

    /**
     * Updates the fields of this ElementInspectionMultimedia object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>InspElement</li>
     * <li>InspectionMultimedia</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(ElementInspectionMultimediaFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [ComponentInspElement] object refered to by the
     * InspElement field.
     *
     * @return InspElement interface
     */
    idempotent ComponentInspElement* getInspElement() throws ServerError;

    /**
     * Gets the proxy to the [InspectionMultimedia] object refered to by the
     * InspectionMultimedia field.
     *
     * @return InspectionMultimedia interface
     */
    idempotent InspectionMultimedia* getInspectionMultimedia() throws ServerError;
  };

  /**
   * Observations associated with Inspection.  
   *
   */
  interface InspectionObservation {
    /**
     * Gets the fields of this InspectionObservation object.
     *
     * @return InspectionObservation object fields
     */
    idempotent InspectionObservationFields getFields() throws ServerError;

    /**
     * Updates the fields of this InspectionObservation object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>InspObservationType</li>
     * <li>ObservationQty</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(InspectionObservationFields fields,
        FieldNameList fieldNames) throws ServerError;
  };

  /**
   * Observations tagged to inspection multi-media. 
   *
   */
  interface InspectionMultimediaTags {
    /**
     * Gets the fields of this InspectionMultimediaTags object.
     *
     * @return InspectionMultimediaTags object fields
     */
    idempotent InspectionMultimediaTagsFields getFields() throws ServerError;

    /**
     * Updates the fields of this InspectionMultimediaTags object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>InspectionMultimedia</li>
     * <li>Observation</li>
     * <li>XCoordinate</li>
     * <li>YCoordinate</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(InspectionMultimediaTagsFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [InspectionMultimedia] object refered to by the
     * InspectionMultimedia field.
     *
     * @return InspectionMultimedia interface
     */
    idempotent InspectionMultimedia* getInspectionMultimedia() throws ServerError;

    /**
     * Gets the proxy to the [InspectionObservation] object refered to by the
     * Observation field.
     *
     * @return Observation interface
     */
    idempotent InspectionObservation* getObservation() throws ServerError;
  };

  /**
   * Point that is part of the geometry of a structure's component 
   *
   */
  interface StructureComponentPoint {
    /**
     * Gets the fields of this StructureComponentPoint object.
     *
     * @return StructureComponentPoint object fields
     */
    idempotent StructureComponentPointFields getFields() throws ServerError;

    /**
     * Updates the fields of this StructureComponentPoint object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Component</li>
     * <li>XCoordinate</li>
     * <li>YCoordinate</li>
     * <li>ZCoordinate</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(StructureComponentPointFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [StructureComponent] object refered to by the
     * Component field.
     *
     * @return Component interface
     */
    idempotent StructureComponent* getComponent() throws ServerError;
  };

  /**
   * CAD models defining bridge component geometry. 
   *
   */
  interface StructureComponentCADModel {
    /**
     * Gets the fields of this StructureComponentCADModel object.
     *
     * @return StructureComponentCADModel object fields
     */
    idempotent StructureComponentCADModelFields getFields() throws ServerError;

    /**
     * Updates the fields of this StructureComponentCADModel object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Component</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(StructureComponentCADModelFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [StructureComponent] object refered to by the
     * Component field.
     *
     * @return Component interface
     */
    idempotent StructureComponent* getComponent() throws ServerError;

    /**
     * Adds a CADModel file.
     *
     * Use the returned file ID to get a writer interface
     * to send the file contents
     * to the server.
     *
     * @param info file information (the size is ignored)
     * @return file ID
     * @see getCADModelFileWriter()
     */
    long addCADModelFileInfo(FileInfo info) throws ServerError;

    /**
     * Deletes a CADModel file if it exists.
     *
     * @param id  file ID
     */
    idempotent void rmCADModelFile(long id) throws ServerError;

    /**
     * Writes a block of data to a CADModel file.
     *
     * @param id      file ID
     * @param offset  starting point of the read (file pointer offset)
     * @param data    data to write
     */
    idempotent void writeCADModelFile(long id, long offset, ByteSeq data) throws ServerError;

    /**
     * Gets information on a CADModel file.
     *
     * @param id file ID
     * @return file information (empty if the file does not exist)
     */
    idempotent FileInfo getCADModelFileInfo(long id) throws ServerError;

    /**
     * Reads a block of data from a CADModel file.
     *
     * This method may return less than the requested number of bytes
     * if the end of the file is reached.
     *
     * @param id      file ID
     * @param offset  starting point of the read (file pointer offset)
     * @param count   number of bytes to read
     */
    idempotent ByteSeq readCADModelFile(long id, long offset, int count) throws ServerError;

    /**
     * Gets the CADModel file info list for the given time range.
     *
     * @param tStart  start of time range \[s]
     * @param tStop   end of time range \[s]
     * @return file information list
     */
    idempotent FileInfoList getCADModelFileInfoList(double tStart, double tStop);
  };

  /**
   * 
   *
   */
  interface CompRepairFinalCond {
    /**
     * Gets the fields of this CompRepairFinalCond object.
     *
     * @return CompRepairFinalCond object fields
     */
    idempotent CompRepairFinalCondFields getFields() throws ServerError;

    /**
     * Updates the fields of this CompRepairFinalCond object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>StructureComponent</li>
     * <li>FinalCondition</li>
     * <li>BestEstimateCost</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(CompRepairFinalCondFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [StructureComponent] object refered to by the
     * StructureComponent field.
     *
     * @return StructureComponent interface
     */
    idempotent StructureComponent* getStructureComponent() throws ServerError;
  };

  /**
   * 
   *
   */
  interface CompRepairTimelineMatrix {
    /**
     * Gets the fields of this CompRepairTimelineMatrix object.
     *
     * @return CompRepairTimelineMatrix object fields
     */
    idempotent CompRepairTimelineMatrixFields getFields() throws ServerError;

    /**
     * Updates the fields of this CompRepairTimelineMatrix object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>StructureComponent</li>
     * <li>OptimizationObjective</li>
     * <li>AssessmentDate</li>
     * <li>YearOfAction</li>
     * <li>ComponentRepairOption</li>
     * <li>RepairOptimizedValue</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(CompRepairTimelineMatrixFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [StructureComponent] object refered to by the
     * StructureComponent field.
     *
     * @return StructureComponent interface
     */
    idempotent StructureComponent* getStructureComponent() throws ServerError;
  };

  /**
   * 
   *
   */
  interface CompEnvBurdenMatrix {
    /**
     * Gets the fields of this CompEnvBurdenMatrix object.
     *
     * @return CompEnvBurdenMatrix object fields
     */
    idempotent CompEnvBurdenMatrixFields getFields() throws ServerError;

    /**
     * Updates the fields of this CompEnvBurdenMatrix object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>StructureComponent</li>
     * <li>OptimizationObjective</li>
     * <li>AssessmentDate</li>
     * <li>EnvImpactType</li>
     * <li>Units</li>
     * <li>EnvOptimizeValue</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(CompEnvBurdenMatrixFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [StructureComponent] object refered to by the
     * StructureComponent field.
     *
     * @return StructureComponent interface
     */
    idempotent StructureComponent* getStructureComponent() throws ServerError;
  };

  /**
   * WIMS (Weigh In Motion Sensor) station. 
   *
   */
  interface WeighInMotionStation {
    /**
     * Gets the fields of this WeighInMotionStation object.
     *
     * @return WeighInMotionStation object fields
     */
    idempotent WeighInMotionStationFields getFields() throws ServerError;

    /**
     * Updates the fields of this WeighInMotionStation object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Structure</li>
     * <li>StateCode</li>
     * <li>CountyCode</li>
     * <li>StationID</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(WeighInMotionStationFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [Structure] object refered to by the
     * Structure field.
     *
     * @return Structure interface
     */
    idempotent Structure* getStructure() throws ServerError;
  };

  /**
   * WIMS (Weigh In Motion Sensor) data. 
   *
   */
  interface WeighInMotionSensorData {
    /**
     * Gets the fields of this WeighInMotionSensorData object.
     *
     * @return WeighInMotionSensorData object fields
     */
    idempotent WeighInMotionSensorDataFields getFields() throws ServerError;

    /**
     * Updates the fields of this WeighInMotionSensorData object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>RecordType</li>
     * <li>Station</li>
     * <li>CollectTime</li>
     * <li>LaneDirection</li>
     * <li>LaneNumber</li>
     * <li>VehicleClass</li>
     * <li>Speed</li>
     * <li>GrossWeight</li>
     * <li>NumberOfAxles</li>
     * <li>WeightAxle1</li>
     * <li>WeightAxle2</li>
     * <li>WeightAxle3</li>
     * <li>WeightAxle4</li>
     * <li>WeightAxle5</li>
     * <li>WeightAxle6</li>
     * <li>WeightAxle7</li>
     * <li>WeightAxle8</li>
     * <li>WeightAxle9</li>
     * <li>WeightAxle10</li>
     * <li>WeightAxle11</li>
     * <li>WeightAxle12</li>
     * <li>WeightAxle13</li>
     * <li>AxleSpacing1to2</li>
     * <li>AxleSpacing2to3</li>
     * <li>AxleSpacing3to4</li>
     * <li>AxleSpacing4to5</li>
     * <li>AxleSpacing5to6</li>
     * <li>AxleSpacing6to7</li>
     * <li>AxleSpacing7to8</li>
     * <li>AxleSpacing8to9</li>
     * <li>AxleSpacing9to10</li>
     * <li>AxleSpacing10to11</li>
     * <li>AxleSpacing11to12</li>
     * <li>AxleSpacing12to13</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(WeighInMotionSensorDataFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [WeighInMotionStation] object refered to by the
     * Station field.
     *
     * @return Station interface
     */
    idempotent WeighInMotionStation* getStation() throws ServerError;
  };

  /**
   * Linear mapping between two node-related quantities. 
   *
   * The axis order is:
   * <ul>
   * <li>OutputNode</li>
   * <li>InputNode</li>
   * </ul>
   */
  interface MappingMatrix {
    /**
     * Gets the fields of this MappingMatrix object.
     *
     * @return MappingMatrix object fields
     */
    idempotent MappingMatrixFields getFields() throws ServerError;

    /**
     * Updates the fields of this MappingMatrix object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Structure</li>
     * <li>Name</li>
     * <li>Description</li>
     * <li>OutputQuantity</li>
     * <li>InputQuantity</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(MappingMatrixFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [Structure] object refered to by the
     * Structure field.
     *
     * @return Structure interface
     */
    idempotent Structure* getStructure() throws ServerError;

    /**
     * Gets the OutputNode axis.
     *
     * @return list of [FEMNode] IDs
     */
    idempotent IdList getOutputNodeAxis() throws ServerError;

    /**
     * Sets the OutputNode axis.
     *
     * @param data list of [FEMNode] IDs
     */
    idempotent void setOutputNodeAxis(IdList data) throws ServerError;

    /**
     * Gets the InputNode axis.
     *
     * @return list of [FEMNode] IDs
     */
    idempotent IdList getInputNodeAxis() throws ServerError;

    /**
     * Sets the InputNode axis.
     *
     * @param data list of [FEMNode] IDs
     */
    idempotent void setInputNodeAxis(IdList data) throws ServerError;

    /**
     * Gets the array dimensions.
     *
     * @return array dimensions
     */
    idempotent DimensionList getArraySize() throws ServerError;

    /**
     * Creates the array.
     *
     * This method must be called before data can be set, or axes
     * defined.
     *
     * @param dims array dimensions
     */
    idempotent void createArray(DimensionList dims) throws ServerError;

    /**
     * Gets a slice of the array data.
     *
     * @param slices  list of slices for each dimension (empty is all)
     * @return array data
     */
    idempotent Float64Array getArrayData(ArraySliceList slices) throws ServerError;

    /**
     * Sets the array data at the given slice.
     *
     * @param slices  list of slices for each dimension (empty is all)
     * @param data vector data
     */
    idempotent void setArrayData(ArraySliceList slices,
                                 Float64List data) throws ServerError;
  };

  /**
   * * Measurement cycle.
 *
 * Defines a single measurement cycle, i.e. taking data from a set of
 * sensors with a common start time, sampling interval, and number of
 * samples.
 *
 * The array defines the link quality of each instrumented sensor channel;
 * a value of 0.0 is used to indicate missing sensor channels.
 *
 * Note that the actual raw data is stored in the corresponding
 * DaqUnitChannelData objects.  The converted data could be stored
 * in the corresponding SensorChannelData objects.
 
   *
   * The axis order is:
   * <ul>
   * <li>Connection</li>
   * </ul>
   */
  interface MeasurementCycle {
    /**
     * Gets the fields of this MeasurementCycle object.
     *
     * @return MeasurementCycle object fields
     */
    idempotent MeasurementCycleFields getFields() throws ServerError;

    /**
     * Updates the fields of this MeasurementCycle object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Structure</li>
     * <li>Start</li>
     * <li>TS</li>
     * <li>Samples</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(MeasurementCycleFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [Structure] object refered to by the
     * Structure field.
     *
     * @return Structure interface
     */
    idempotent Structure* getStructure() throws ServerError;

    /**
     * Gets the Connection axis.
     *
     * @return list of [SensorChannelConnection] IDs
     */
    idempotent IdList getConnectionAxis() throws ServerError;

    /**
     * Sets the Connection axis.
     *
     * @param data list of [SensorChannelConnection] IDs
     */
    idempotent void setConnectionAxis(IdList data) throws ServerError;

    /**
     * Gets the array dimensions.
     *
     * @return array dimensions
     */
    idempotent DimensionList getArraySize() throws ServerError;

    /**
     * Creates the array.
     *
     * This method must be called before data can be set, or axes
     * defined.
     *
     * @param dims array dimensions
     */
    idempotent void createArray(DimensionList dims) throws ServerError;

    /**
     * Gets a slice of the array data.
     *
     * @param slices  list of slices for each dimension (empty is all)
     * @return array data
     */
    idempotent Float32Array getArrayData(ArraySliceList slices) throws ServerError;

    /**
     * Sets the array data at the given slice.
     *
     * @param slices  list of slices for each dimension (empty is all)
     * @param data vector data
     */
    idempotent void setArrayData(ArraySliceList slices,
                                 Float32List data) throws ServerError;
  };

  /**
   * 2D mapping from (unit) load location and sensor channel to computed sensor reading. 
   *
   * The axis order is:
   * <ul>
   * <li>Location</li>
   * <li>Connection</li>
   * </ul>
   */
  interface StaticLoadToSensorMapping {
    /**
     * Gets the fields of this StaticLoadToSensorMapping object.
     *
     * @return StaticLoadToSensorMapping object fields
     */
    idempotent StaticLoadToSensorMappingFields getFields() throws ServerError;

    /**
     * Updates the fields of this StaticLoadToSensorMapping object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Structure</li>
     * <li>Date</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(StaticLoadToSensorMappingFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [Structure] object refered to by the
     * Structure field.
     *
     * @return Structure interface
     */
    idempotent Structure* getStructure() throws ServerError;

    /**
     * Gets the Location axis.
     *
     * @return list of [FEMNode] IDs
     */
    idempotent IdList getLocationAxis() throws ServerError;

    /**
     * Sets the Location axis.
     *
     * @param data list of [FEMNode] IDs
     */
    idempotent void setLocationAxis(IdList data) throws ServerError;

    /**
     * Gets the Connection axis.
     *
     * @return list of [SensorChannelConnection] IDs
     */
    idempotent IdList getConnectionAxis() throws ServerError;

    /**
     * Sets the Connection axis.
     *
     * @param data list of [SensorChannelConnection] IDs
     */
    idempotent void setConnectionAxis(IdList data) throws ServerError;

    /**
     * Gets the array dimensions.
     *
     * @return array dimensions
     */
    idempotent DimensionList getArraySize() throws ServerError;

    /**
     * Creates the array.
     *
     * This method must be called before data can be set, or axes
     * defined.
     *
     * @param dims array dimensions
     */
    idempotent void createArray(DimensionList dims) throws ServerError;

    /**
     * Gets a slice of the array data.
     *
     * @param slices  list of slices for each dimension (empty is all)
     * @return array data
     */
    idempotent Float32Array getArrayData(ArraySliceList slices) throws ServerError;

    /**
     * Sets the array data at the given slice.
     *
     * @param slices  list of slices for each dimension (empty is all)
     * @param data vector data
     */
    idempotent void setArrayData(ArraySliceList slices,
                                 Float32List data) throws ServerError;
  };

  /**
   * * Data acquisition unit raw channel data.
 
   *
   * The axis order is:
   * <ul>
   * <li>SubChannels</li>
   * </ul>
   */
  interface DaqUnitChannelData {
    /**
     * Gets the fields of this DaqUnitChannelData object.
     *
     * @return DaqUnitChannelData object fields
     */
    idempotent DaqUnitChannelDataFields getFields() throws ServerError;

    /**
     * Updates the fields of this DaqUnitChannelData object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Channel</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(DaqUnitChannelDataFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [DaqUnitChannel] object refered to by the
     * Channel field.
     *
     * @return Channel interface
     */
    idempotent DaqUnitChannel* getChannel() throws ServerError;

    /**
     * Gets the SubChannels axis.
     *
     * @return list of [Quantity]s
     */
    idempotent QuantityList getSubChannelsAxis() throws ServerError;

    /**
     * Gets the SubChannels axis.
     *
     * @param data list of [Quantity]s
     */
    idempotent void setSubChannelsAxis(QuantityList data) throws ServerError;

    /**
     * Gets the signal dimensions.
     *
     * Note that the number of dimensions equals the number of axes
     * plus one (for the time axis).  The first element of the
     * dimension list is the time dimension.
     *
     * @return signal dimensions
     */
    idempotent DimensionList getSignalSize() throws ServerError;

    /**
     * Creates the signal array.
     *
     * Note that the array size reflects the size of each axis, not
     * including the time axis.  The signal will grow along the time
     * axis as arrays are added.
     *
     * This method must be called before signal samples can be added,
     * or axes can be set.
     *
     * @param dims signal array dimensions
     */
    idempotent void createSignal(DimensionList dims) throws ServerError;

    /**
     * Gets the time axis information.
     *
     * Returns a data structure with information on how many samples
     * of data are available in the given time range.  The returned
     * time range will be trimmed to the range for which data is
     * available.
     *
     * If the time vector is empty, the beginning and end of the
     * available data are returned.
     *
     * @param t  vector with time stamps \[s]
     * @return time axis information structure
     */
    idempotent TimeAxisInfo getTimeAxisInfo(TimestampList t) throws ServerError;

    /**
     * Gets the time axis corresponding to an index range.
     *
     * Returns the time stamps for the given index range.  The returned
     * time range will be trimmed if the index exceeds the actual number
     * of available samples.  The caller must make sure that the indices
     * are valid, to ensure a one-to-one correspondence between the indices
     * requested and the time-stamps returned.
     *
     * @param idxStart  start index (included in data)
     * @param idxStep   index step size
     * @param idxStop   stop index (not included in data)
     * @return vector with time stamps \[s]
     */
    idempotent TimestampList getTimeAxisByIndexRange(long idxStart, long idxStep, long idxStop) throws ServerError;

    /**
     * Gets the signal data.
     *
     * The returned signal data will have time stamps tStart <= t <=
     * tEnd, with no two time stamps closer than tDelta.  No interpolation
     * performed, only available samples are returned.
     *
     * @param tStart  start time
     * @param tDelta  minimum time interval \[s]
     * @param tEnd   stop time
     * @param slices  list of slices for each dimension (empty is all)
     * @return signal structure
     */
    idempotent Int32Signal getSignalData(double tStart, float tStep, double tEnd,
        ArraySliceList slices) throws ServerError;

    /**
     * Gets the signal data by index range.
     *
     * The returned signal data will contain samples
     * \[idxStart,  idxStart+idxStep, idxStart+2*idxStep, ...],
     * where idx < idxStop.
     *
     * @param idxStart  start index (included in data)
     * @param idxStep   index step size
     * @param idxStop   stop index (not included in data)
     * @param slices    list of slices for each dimension (empty is all)
     * @return signal structure
     */
    idempotent Int32Signal getSignalDataByIndexRange(long idxStart, long idxStep, long idxStop,
        ArraySliceList slices) throws ServerError;

    /**
     * Appends a set of data points to the signal.
     *
     * This is the most efficient method to add signal data,
     * but requires data that is monotonically increasing in time, and
     * is newer than the existing data.
     *
     * The data vector is interpreted as an array of compatible
     * dimension.  The storage order is last dimension (axis) moves
     * fastest.
     *
     * @param t     ordered list of time stamps
     * @param data  signal array data
     */
    void appendToSignal(TimestampList t, Int32List data) throws ServerError;

    /**
     * Sets data points in this signal.
     *
     * The data is inserted where the timestamps are new, and replaces
     * existing data where the timestamps already exist.  The data does
     * not need to be monotonically increasing in time.
     *
     * The data vector is interpreted as an array of compatible
     * dimension.  The storage order is last dimension (axis) moves
     * fastest.
     *
     * @param t     list of time stamps
     * @param data  signal array data
     * @throws DataReadError if the data is not correct (wrong ID, size, or time axis order) 
     */
    void setSignal(TimestampList t, Int32List data) throws ServerError;
  };

  /**
   * * Sensor channel data.
 *
 * The sensor data is typically based on raw data, which is converted
 * to physically meaningful values.
 
   *
   * The axis order is:
   * <ul>
   * <li>SubChannels</li>
   * </ul>
   */
  interface SensorChannelData {
    /**
     * Gets the fields of this SensorChannelData object.
     *
     * @return SensorChannelData object fields
     */
    idempotent SensorChannelDataFields getFields() throws ServerError;

    /**
     * Updates the fields of this SensorChannelData object.
     *
     * If one or more fields are specified, only the fields listed
     * will be updated, the other fields will be left unchanged.  If
     * the field list is empty ALL fields will be updated.
     * The available fields are:
     * <ul>
     * <li>Channel</li>
     * </ul>
     *
     * @param fields      updated fields structure
     * @param fieldNames  a string list with field names to be updated
     */
    idempotent void setFields(SensorChannelDataFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Gets the proxy to the [SensorChannel] object refered to by the
     * Channel field.
     *
     * @return Channel interface
     */
    idempotent SensorChannel* getChannel() throws ServerError;

    /**
     * Gets the SubChannels axis.
     *
     * @return list of [Quantity]s
     */
    idempotent QuantityList getSubChannelsAxis() throws ServerError;

    /**
     * Gets the SubChannels axis.
     *
     * @param data list of [Quantity]s
     */
    idempotent void setSubChannelsAxis(QuantityList data) throws ServerError;

    /**
     * Gets the signal dimensions.
     *
     * Note that the number of dimensions equals the number of axes
     * plus one (for the time axis).  The first element of the
     * dimension list is the time dimension.
     *
     * @return signal dimensions
     */
    idempotent DimensionList getSignalSize() throws ServerError;

    /**
     * Creates the signal array.
     *
     * Note that the array size reflects the size of each axis, not
     * including the time axis.  The signal will grow along the time
     * axis as arrays are added.
     *
     * This method must be called before signal samples can be added,
     * or axes can be set.
     *
     * @param dims signal array dimensions
     */
    idempotent void createSignal(DimensionList dims) throws ServerError;

    /**
     * Gets the time axis information.
     *
     * Returns a data structure with information on how many samples
     * of data are available in the given time range.  The returned
     * time range will be trimmed to the range for which data is
     * available.
     *
     * If the time vector is empty, the beginning and end of the
     * available data are returned.
     *
     * @param t  vector with time stamps \[s]
     * @return time axis information structure
     */
    idempotent TimeAxisInfo getTimeAxisInfo(TimestampList t) throws ServerError;

    /**
     * Gets the time axis corresponding to an index range.
     *
     * Returns the time stamps for the given index range.  The returned
     * time range will be trimmed if the index exceeds the actual number
     * of available samples.  The caller must make sure that the indices
     * are valid, to ensure a one-to-one correspondence between the indices
     * requested and the time-stamps returned.
     *
     * @param idxStart  start index (included in data)
     * @param idxStep   index step size
     * @param idxStop   stop index (not included in data)
     * @return vector with time stamps \[s]
     */
    idempotent TimestampList getTimeAxisByIndexRange(long idxStart, long idxStep, long idxStop) throws ServerError;

    /**
     * Gets the signal data.
     *
     * The returned signal data will have time stamps tStart <= t <=
     * tEnd, with no two time stamps closer than tDelta.  No interpolation
     * performed, only available samples are returned.
     *
     * @param tStart  start time
     * @param tDelta  minimum time interval \[s]
     * @param tEnd   stop time
     * @param slices  list of slices for each dimension (empty is all)
     * @return signal structure
     */
    idempotent Float32Signal getSignalData(double tStart, float tStep, double tEnd,
        ArraySliceList slices) throws ServerError;

    /**
     * Gets the signal data by index range.
     *
     * The returned signal data will contain samples
     * \[idxStart,  idxStart+idxStep, idxStart+2*idxStep, ...],
     * where idx < idxStop.
     *
     * @param idxStart  start index (included in data)
     * @param idxStep   index step size
     * @param idxStop   stop index (not included in data)
     * @param slices    list of slices for each dimension (empty is all)
     * @return signal structure
     */
    idempotent Float32Signal getSignalDataByIndexRange(long idxStart, long idxStep, long idxStop,
        ArraySliceList slices) throws ServerError;

    /**
     * Appends a set of data points to the signal.
     *
     * This is the most efficient method to add signal data,
     * but requires data that is monotonically increasing in time, and
     * is newer than the existing data.
     *
     * The data vector is interpreted as an array of compatible
     * dimension.  The storage order is last dimension (axis) moves
     * fastest.
     *
     * @param t     ordered list of time stamps
     * @param data  signal array data
     */
    void appendToSignal(TimestampList t, Float32List data) throws ServerError;

    /**
     * Sets data points in this signal.
     *
     * The data is inserted where the timestamps are new, and replaces
     * existing data where the timestamps already exist.  The data does
     * not need to be monotonically increasing in time.
     *
     * The data vector is interpreted as an array of compatible
     * dimension.  The storage order is last dimension (axis) moves
     * fastest.
     *
     * @param t     list of time stamps
     * @param data  signal array data
     * @throws DataReadError if the data is not correct (wrong ID, size, or time axis order) 
     */
    void setSignal(TimestampList t, Float32List data) throws ServerError;
  };

  interface SenStoreMngr {
    /**
     * Logs in to the manager.
     *
     * @param username   user name
     * @param password   user password
     */
    idempotent void login(string username, string password) throws ServerError;
    
    /**
     * Checks if the user is loggin into the manager.
     */
    idempotent bool isLoggedIn();
    
    /**
     * Gets the name of the currently logged-in user.
     */
    string getUserName();
    
    /**
     * Gets the groups of the currently logged-in user.
     */
    StringList getUserGroups();

    /**
     * Logs out of the manager.
     */
    idempotent void logout();


    /**
     * Adds a UserGroup object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addUserGroup(UserGroupFields fields) throws ServerError;

    /**
     * Adds a set of UserGroup objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addUserGroupList(UserGroupFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified UserGroup object.
     *
     * @param id  UserGroup object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delUserGroup(long id) throws ServerError;

    /**
     * Gets the UserGroup object proxy.
     *
     * @param id  UserGroup object ID
     * @return UserGroup object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent UserGroup* getUserGroup(long id) throws ServerError;

    /**
     * Gets a list of all UserGroup object IDs.
     *
     * @return list of UserGroup object IDs
     */
    idempotent IdList getUserGroupIds() throws ServerError;

    /**
     * Gets a list of UserGroup object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of UserGroup object IDs
     * @return list of UserGroup object proxies
     */
    idempotent UserGroupList getUserGroupList(IdList ids) throws ServerError;

    /**
     * Gets the UserGroup object fields.
     *
     * @param id UserGroup object ID
     * @return UserGroup object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent UserGroupFields getUserGroupFields(long id) throws ServerError;

    /**
     * Gets a list of UserGroup object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of UserGroup object IDs
     * @return list of UserGroup object fields
     */
    idempotent UserGroupFieldsList getUserGroupFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all UserGroup objects matching the given
     * reference fields.
     *
     * @param fields UserGroup object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching UserGroup objects
     */
    idempotent IdList findEqualUserGroup(UserGroupFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named UserGroup object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields UserGroup object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setUserGroupFields(UserGroupFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named UserGroup object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setUserGroupFieldsList(UserGroupFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a User object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addUser(UserFields fields) throws ServerError;

    /**
     * Adds a set of User objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addUserList(UserFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified User object.
     *
     * @param id  User object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delUser(long id) throws ServerError;

    /**
     * Gets the User object proxy.
     *
     * @param id  User object ID
     * @return User object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent User* getUser(long id) throws ServerError;

    /**
     * Gets a list of all User object IDs.
     *
     * @return list of User object IDs
     */
    idempotent IdList getUserIds() throws ServerError;

    /**
     * Gets a list of User object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of User object IDs
     * @return list of User object proxies
     */
    idempotent UserList getUserList(IdList ids) throws ServerError;

    /**
     * Gets the User object fields.
     *
     * @param id User object ID
     * @return User object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent UserFields getUserFields(long id) throws ServerError;

    /**
     * Gets a list of User object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of User object IDs
     * @return list of User object fields
     */
    idempotent UserFieldsList getUserFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all User objects matching the given
     * reference fields.
     *
     * @param fields User object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching User objects
     */
    idempotent IdList findEqualUser(UserFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named User object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields User object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setUserFields(UserFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named User object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setUserFieldsList(UserFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a UserGroupMembership object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addUserGroupMembership(UserGroupMembershipFields fields) throws ServerError;

    /**
     * Adds a set of UserGroupMembership objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addUserGroupMembershipList(UserGroupMembershipFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified UserGroupMembership object.
     *
     * @param id  UserGroupMembership object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delUserGroupMembership(long id) throws ServerError;

    /**
     * Gets the UserGroupMembership object proxy.
     *
     * @param id  UserGroupMembership object ID
     * @return UserGroupMembership object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent UserGroupMembership* getUserGroupMembership(long id) throws ServerError;

    /**
     * Gets a list of all UserGroupMembership object IDs.
     *
     * @return list of UserGroupMembership object IDs
     */
    idempotent IdList getUserGroupMembershipIds() throws ServerError;

    /**
     * Gets a list of UserGroupMembership object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of UserGroupMembership object IDs
     * @return list of UserGroupMembership object proxies
     */
    idempotent UserGroupMembershipList getUserGroupMembershipList(IdList ids) throws ServerError;

    /**
     * Gets the UserGroupMembership object fields.
     *
     * @param id UserGroupMembership object ID
     * @return UserGroupMembership object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent UserGroupMembershipFields getUserGroupMembershipFields(long id) throws ServerError;

    /**
     * Gets a list of UserGroupMembership object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of UserGroupMembership object IDs
     * @return list of UserGroupMembership object fields
     */
    idempotent UserGroupMembershipFieldsList getUserGroupMembershipFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all UserGroupMembership objects matching the given
     * reference fields.
     *
     * @param fields UserGroupMembership object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching UserGroupMembership objects
     */
    idempotent IdList findEqualUserGroupMembership(UserGroupMembershipFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named UserGroupMembership object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields UserGroupMembership object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setUserGroupMembershipFields(UserGroupMembershipFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named UserGroupMembership object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setUserGroupMembershipFieldsList(UserGroupMembershipFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a NotificationCategory object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addNotificationCategory(NotificationCategoryFields fields) throws ServerError;

    /**
     * Adds a set of NotificationCategory objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addNotificationCategoryList(NotificationCategoryFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified NotificationCategory object.
     *
     * @param id  NotificationCategory object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delNotificationCategory(long id) throws ServerError;

    /**
     * Gets the NotificationCategory object proxy.
     *
     * @param id  NotificationCategory object ID
     * @return NotificationCategory object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent NotificationCategory* getNotificationCategory(long id) throws ServerError;

    /**
     * Gets a list of all NotificationCategory object IDs.
     *
     * @return list of NotificationCategory object IDs
     */
    idempotent IdList getNotificationCategoryIds() throws ServerError;

    /**
     * Gets a list of NotificationCategory object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of NotificationCategory object IDs
     * @return list of NotificationCategory object proxies
     */
    idempotent NotificationCategoryList getNotificationCategoryList(IdList ids) throws ServerError;

    /**
     * Gets the NotificationCategory object fields.
     *
     * @param id NotificationCategory object ID
     * @return NotificationCategory object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent NotificationCategoryFields getNotificationCategoryFields(long id) throws ServerError;

    /**
     * Gets a list of NotificationCategory object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of NotificationCategory object IDs
     * @return list of NotificationCategory object fields
     */
    idempotent NotificationCategoryFieldsList getNotificationCategoryFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all NotificationCategory objects matching the given
     * reference fields.
     *
     * @param fields NotificationCategory object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching NotificationCategory objects
     */
    idempotent IdList findEqualNotificationCategory(NotificationCategoryFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named NotificationCategory object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields NotificationCategory object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setNotificationCategoryFields(NotificationCategoryFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named NotificationCategory object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setNotificationCategoryFieldsList(NotificationCategoryFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a NotificationMembership object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addNotificationMembership(NotificationMembershipFields fields) throws ServerError;

    /**
     * Adds a set of NotificationMembership objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addNotificationMembershipList(NotificationMembershipFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified NotificationMembership object.
     *
     * @param id  NotificationMembership object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delNotificationMembership(long id) throws ServerError;

    /**
     * Gets the NotificationMembership object proxy.
     *
     * @param id  NotificationMembership object ID
     * @return NotificationMembership object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent NotificationMembership* getNotificationMembership(long id) throws ServerError;

    /**
     * Gets a list of all NotificationMembership object IDs.
     *
     * @return list of NotificationMembership object IDs
     */
    idempotent IdList getNotificationMembershipIds() throws ServerError;

    /**
     * Gets a list of NotificationMembership object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of NotificationMembership object IDs
     * @return list of NotificationMembership object proxies
     */
    idempotent NotificationMembershipList getNotificationMembershipList(IdList ids) throws ServerError;

    /**
     * Gets the NotificationMembership object fields.
     *
     * @param id NotificationMembership object ID
     * @return NotificationMembership object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent NotificationMembershipFields getNotificationMembershipFields(long id) throws ServerError;

    /**
     * Gets a list of NotificationMembership object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of NotificationMembership object IDs
     * @return list of NotificationMembership object fields
     */
    idempotent NotificationMembershipFieldsList getNotificationMembershipFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all NotificationMembership objects matching the given
     * reference fields.
     *
     * @param fields NotificationMembership object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching NotificationMembership objects
     */
    idempotent IdList findEqualNotificationMembership(NotificationMembershipFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named NotificationMembership object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields NotificationMembership object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setNotificationMembershipFields(NotificationMembershipFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named NotificationMembership object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setNotificationMembershipFieldsList(NotificationMembershipFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a StructureOwner object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addStructureOwner(StructureOwnerFields fields) throws ServerError;

    /**
     * Adds a set of StructureOwner objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addStructureOwnerList(StructureOwnerFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified StructureOwner object.
     *
     * @param id  StructureOwner object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delStructureOwner(long id) throws ServerError;

    /**
     * Gets the StructureOwner object proxy.
     *
     * @param id  StructureOwner object ID
     * @return StructureOwner object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent StructureOwner* getStructureOwner(long id) throws ServerError;

    /**
     * Gets a list of all StructureOwner object IDs.
     *
     * @return list of StructureOwner object IDs
     */
    idempotent IdList getStructureOwnerIds() throws ServerError;

    /**
     * Gets a list of StructureOwner object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of StructureOwner object IDs
     * @return list of StructureOwner object proxies
     */
    idempotent StructureOwnerList getStructureOwnerList(IdList ids) throws ServerError;

    /**
     * Gets the StructureOwner object fields.
     *
     * @param id StructureOwner object ID
     * @return StructureOwner object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent StructureOwnerFields getStructureOwnerFields(long id) throws ServerError;

    /**
     * Gets a list of StructureOwner object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of StructureOwner object IDs
     * @return list of StructureOwner object fields
     */
    idempotent StructureOwnerFieldsList getStructureOwnerFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all StructureOwner objects matching the given
     * reference fields.
     *
     * @param fields StructureOwner object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching StructureOwner objects
     */
    idempotent IdList findEqualStructureOwner(StructureOwnerFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named StructureOwner object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields StructureOwner object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setStructureOwnerFields(StructureOwnerFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named StructureOwner object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setStructureOwnerFieldsList(StructureOwnerFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a Structure object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addStructure(StructureFields fields) throws ServerError;

    /**
     * Adds a set of Structure objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addStructureList(StructureFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified Structure object.
     *
     * @param id  Structure object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delStructure(long id) throws ServerError;

    /**
     * Gets the Structure object proxy.
     *
     * @param id  Structure object ID
     * @return Structure object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent Structure* getStructure(long id) throws ServerError;

    /**
     * Gets a list of all Structure object IDs.
     *
     * @return list of Structure object IDs
     */
    idempotent IdList getStructureIds() throws ServerError;

    /**
     * Gets a list of Structure object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of Structure object IDs
     * @return list of Structure object proxies
     */
    idempotent StructureList getStructureList(IdList ids) throws ServerError;

    /**
     * Gets the Structure object fields.
     *
     * @param id Structure object ID
     * @return Structure object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent StructureFields getStructureFields(long id) throws ServerError;

    /**
     * Gets a list of Structure object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of Structure object IDs
     * @return list of Structure object fields
     */
    idempotent StructureFieldsList getStructureFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all Structure objects matching the given
     * reference fields.
     *
     * @param fields Structure object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching Structure objects
     */
    idempotent IdList findEqualStructure(StructureFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named Structure object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields Structure object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setStructureFields(StructureFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named Structure object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setStructureFieldsList(StructureFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMDof object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMDof(FEMDofFields fields) throws ServerError;

    /**
     * Adds a set of FEMDof objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMDofList(FEMDofFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMDof object.
     *
     * @param id  FEMDof object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMDof(long id) throws ServerError;

    /**
     * Gets the FEMDof object proxy.
     *
     * @param id  FEMDof object ID
     * @return FEMDof object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMDof* getFEMDof(long id) throws ServerError;

    /**
     * Gets a list of all FEMDof object IDs.
     *
     * @return list of FEMDof object IDs
     */
    idempotent IdList getFEMDofIds() throws ServerError;

    /**
     * Gets a list of FEMDof object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMDof object IDs
     * @return list of FEMDof object proxies
     */
    idempotent FEMDofList getFEMDofList(IdList ids) throws ServerError;

    /**
     * Gets the FEMDof object fields.
     *
     * @param id FEMDof object ID
     * @return FEMDof object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMDofFields getFEMDofFields(long id) throws ServerError;

    /**
     * Gets a list of FEMDof object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMDof object IDs
     * @return list of FEMDof object fields
     */
    idempotent FEMDofFieldsList getFEMDofFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMDof objects matching the given
     * reference fields.
     *
     * @param fields FEMDof object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMDof objects
     */
    idempotent IdList findEqualFEMDof(FEMDofFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMDof object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMDof object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMDofFields(FEMDofFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMDof object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMDofFieldsList(FEMDofFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMNodalMass object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMNodalMass(FEMNodalMassFields fields) throws ServerError;

    /**
     * Adds a set of FEMNodalMass objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMNodalMassList(FEMNodalMassFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMNodalMass object.
     *
     * @param id  FEMNodalMass object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMNodalMass(long id) throws ServerError;

    /**
     * Gets the FEMNodalMass object proxy.
     *
     * @param id  FEMNodalMass object ID
     * @return FEMNodalMass object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMNodalMass* getFEMNodalMass(long id) throws ServerError;

    /**
     * Gets a list of all FEMNodalMass object IDs.
     *
     * @return list of FEMNodalMass object IDs
     */
    idempotent IdList getFEMNodalMassIds() throws ServerError;

    /**
     * Gets a list of FEMNodalMass object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMNodalMass object IDs
     * @return list of FEMNodalMass object proxies
     */
    idempotent FEMNodalMassList getFEMNodalMassList(IdList ids) throws ServerError;

    /**
     * Gets the FEMNodalMass object fields.
     *
     * @param id FEMNodalMass object ID
     * @return FEMNodalMass object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMNodalMassFields getFEMNodalMassFields(long id) throws ServerError;

    /**
     * Gets a list of FEMNodalMass object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMNodalMass object IDs
     * @return list of FEMNodalMass object fields
     */
    idempotent FEMNodalMassFieldsList getFEMNodalMassFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMNodalMass objects matching the given
     * reference fields.
     *
     * @param fields FEMNodalMass object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMNodalMass objects
     */
    idempotent IdList findEqualFEMNodalMass(FEMNodalMassFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMNodalMass object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMNodalMass object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMNodalMassFields(FEMNodalMassFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMNodalMass object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMNodalMassFieldsList(FEMNodalMassFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMNLElasticStrainStress object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMNLElasticStrainStress(FEMNLElasticStrainStressFields fields) throws ServerError;

    /**
     * Adds a set of FEMNLElasticStrainStress objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMNLElasticStrainStressList(FEMNLElasticStrainStressFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMNLElasticStrainStress object.
     *
     * @param id  FEMNLElasticStrainStress object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMNLElasticStrainStress(long id) throws ServerError;

    /**
     * Gets the FEMNLElasticStrainStress object proxy.
     *
     * @param id  FEMNLElasticStrainStress object ID
     * @return FEMNLElasticStrainStress object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMNLElasticStrainStress* getFEMNLElasticStrainStress(long id) throws ServerError;

    /**
     * Gets a list of all FEMNLElasticStrainStress object IDs.
     *
     * @return list of FEMNLElasticStrainStress object IDs
     */
    idempotent IdList getFEMNLElasticStrainStressIds() throws ServerError;

    /**
     * Gets a list of FEMNLElasticStrainStress object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMNLElasticStrainStress object IDs
     * @return list of FEMNLElasticStrainStress object proxies
     */
    idempotent FEMNLElasticStrainStressList getFEMNLElasticStrainStressList(IdList ids) throws ServerError;

    /**
     * Gets the FEMNLElasticStrainStress object fields.
     *
     * @param id FEMNLElasticStrainStress object ID
     * @return FEMNLElasticStrainStress object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMNLElasticStrainStressFields getFEMNLElasticStrainStressFields(long id) throws ServerError;

    /**
     * Gets a list of FEMNLElasticStrainStress object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMNLElasticStrainStress object IDs
     * @return list of FEMNLElasticStrainStress object fields
     */
    idempotent FEMNLElasticStrainStressFieldsList getFEMNLElasticStrainStressFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMNLElasticStrainStress objects matching the given
     * reference fields.
     *
     * @param fields FEMNLElasticStrainStress object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMNLElasticStrainStress objects
     */
    idempotent IdList findEqualFEMNLElasticStrainStress(FEMNLElasticStrainStressFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMNLElasticStrainStress object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMNLElasticStrainStress object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMNLElasticStrainStressFields(FEMNLElasticStrainStressFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMNLElasticStrainStress object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMNLElasticStrainStressFieldsList(FEMNLElasticStrainStressFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMBoundary object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMBoundary(FEMBoundaryFields fields) throws ServerError;

    /**
     * Adds a set of FEMBoundary objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMBoundaryList(FEMBoundaryFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMBoundary object.
     *
     * @param id  FEMBoundary object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMBoundary(long id) throws ServerError;

    /**
     * Gets the FEMBoundary object proxy.
     *
     * @param id  FEMBoundary object ID
     * @return FEMBoundary object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMBoundary* getFEMBoundary(long id) throws ServerError;

    /**
     * Gets a list of all FEMBoundary object IDs.
     *
     * @return list of FEMBoundary object IDs
     */
    idempotent IdList getFEMBoundaryIds() throws ServerError;

    /**
     * Gets a list of FEMBoundary object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMBoundary object IDs
     * @return list of FEMBoundary object proxies
     */
    idempotent FEMBoundaryList getFEMBoundaryList(IdList ids) throws ServerError;

    /**
     * Gets the FEMBoundary object fields.
     *
     * @param id FEMBoundary object ID
     * @return FEMBoundary object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMBoundaryFields getFEMBoundaryFields(long id) throws ServerError;

    /**
     * Gets a list of FEMBoundary object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMBoundary object IDs
     * @return list of FEMBoundary object fields
     */
    idempotent FEMBoundaryFieldsList getFEMBoundaryFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMBoundary objects matching the given
     * reference fields.
     *
     * @param fields FEMBoundary object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMBoundary objects
     */
    idempotent IdList findEqualFEMBoundary(FEMBoundaryFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMBoundary object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMBoundary object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMBoundaryFields(FEMBoundaryFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMBoundary object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMBoundaryFieldsList(FEMBoundaryFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMSectionPipe object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMSectionPipe(FEMSectionPipeFields fields) throws ServerError;

    /**
     * Adds a set of FEMSectionPipe objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMSectionPipeList(FEMSectionPipeFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMSectionPipe object.
     *
     * @param id  FEMSectionPipe object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMSectionPipe(long id) throws ServerError;

    /**
     * Gets the FEMSectionPipe object proxy.
     *
     * @param id  FEMSectionPipe object ID
     * @return FEMSectionPipe object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMSectionPipe* getFEMSectionPipe(long id) throws ServerError;

    /**
     * Gets a list of all FEMSectionPipe object IDs.
     *
     * @return list of FEMSectionPipe object IDs
     */
    idempotent IdList getFEMSectionPipeIds() throws ServerError;

    /**
     * Gets a list of FEMSectionPipe object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMSectionPipe object IDs
     * @return list of FEMSectionPipe object proxies
     */
    idempotent FEMSectionPipeList getFEMSectionPipeList(IdList ids) throws ServerError;

    /**
     * Gets the FEMSectionPipe object fields.
     *
     * @param id FEMSectionPipe object ID
     * @return FEMSectionPipe object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMSectionPipeFields getFEMSectionPipeFields(long id) throws ServerError;

    /**
     * Gets a list of FEMSectionPipe object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMSectionPipe object IDs
     * @return list of FEMSectionPipe object fields
     */
    idempotent FEMSectionPipeFieldsList getFEMSectionPipeFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMSectionPipe objects matching the given
     * reference fields.
     *
     * @param fields FEMSectionPipe object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMSectionPipe objects
     */
    idempotent IdList findEqualFEMSectionPipe(FEMSectionPipeFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMSectionPipe object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMSectionPipe object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMSectionPipeFields(FEMSectionPipeFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMSectionPipe object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMSectionPipeFieldsList(FEMSectionPipeFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMCoordSystem object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMCoordSystem(FEMCoordSystemFields fields) throws ServerError;

    /**
     * Adds a set of FEMCoordSystem objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMCoordSystemList(FEMCoordSystemFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMCoordSystem object.
     *
     * @param id  FEMCoordSystem object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMCoordSystem(long id) throws ServerError;

    /**
     * Gets the FEMCoordSystem object proxy.
     *
     * @param id  FEMCoordSystem object ID
     * @return FEMCoordSystem object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMCoordSystem* getFEMCoordSystem(long id) throws ServerError;

    /**
     * Gets a list of all FEMCoordSystem object IDs.
     *
     * @return list of FEMCoordSystem object IDs
     */
    idempotent IdList getFEMCoordSystemIds() throws ServerError;

    /**
     * Gets a list of FEMCoordSystem object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMCoordSystem object IDs
     * @return list of FEMCoordSystem object proxies
     */
    idempotent FEMCoordSystemList getFEMCoordSystemList(IdList ids) throws ServerError;

    /**
     * Gets the FEMCoordSystem object fields.
     *
     * @param id FEMCoordSystem object ID
     * @return FEMCoordSystem object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMCoordSystemFields getFEMCoordSystemFields(long id) throws ServerError;

    /**
     * Gets a list of FEMCoordSystem object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMCoordSystem object IDs
     * @return list of FEMCoordSystem object fields
     */
    idempotent FEMCoordSystemFieldsList getFEMCoordSystemFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMCoordSystem objects matching the given
     * reference fields.
     *
     * @param fields FEMCoordSystem object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMCoordSystem objects
     */
    idempotent IdList findEqualFEMCoordSystem(FEMCoordSystemFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMCoordSystem object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMCoordSystem object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMCoordSystemFields(FEMCoordSystemFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMCoordSystem object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMCoordSystemFieldsList(FEMCoordSystemFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMNode object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMNode(FEMNodeFields fields) throws ServerError;

    /**
     * Adds a set of FEMNode objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMNodeList(FEMNodeFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMNode object.
     *
     * @param id  FEMNode object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMNode(long id) throws ServerError;

    /**
     * Gets the FEMNode object proxy.
     *
     * @param id  FEMNode object ID
     * @return FEMNode object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMNode* getFEMNode(long id) throws ServerError;

    /**
     * Gets a list of all FEMNode object IDs.
     *
     * @return list of FEMNode object IDs
     */
    idempotent IdList getFEMNodeIds() throws ServerError;

    /**
     * Gets a list of FEMNode object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMNode object IDs
     * @return list of FEMNode object proxies
     */
    idempotent FEMNodeList getFEMNodeList(IdList ids) throws ServerError;

    /**
     * Gets the FEMNode object fields.
     *
     * @param id FEMNode object ID
     * @return FEMNode object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMNodeFields getFEMNodeFields(long id) throws ServerError;

    /**
     * Gets a list of FEMNode object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMNode object IDs
     * @return list of FEMNode object fields
     */
    idempotent FEMNodeFieldsList getFEMNodeFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMNode objects matching the given
     * reference fields.
     *
     * @param fields FEMNode object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMNode objects
     */
    idempotent IdList findEqualFEMNode(FEMNodeFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMNode object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMNode object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMNodeFields(FEMNodeFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMNode object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMNodeFieldsList(FEMNodeFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMTruss object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMTruss(FEMTrussFields fields) throws ServerError;

    /**
     * Adds a set of FEMTruss objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMTrussList(FEMTrussFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMTruss object.
     *
     * @param id  FEMTruss object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMTruss(long id) throws ServerError;

    /**
     * Gets the FEMTruss object proxy.
     *
     * @param id  FEMTruss object ID
     * @return FEMTruss object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMTruss* getFEMTruss(long id) throws ServerError;

    /**
     * Gets a list of all FEMTruss object IDs.
     *
     * @return list of FEMTruss object IDs
     */
    idempotent IdList getFEMTrussIds() throws ServerError;

    /**
     * Gets a list of FEMTruss object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMTruss object IDs
     * @return list of FEMTruss object proxies
     */
    idempotent FEMTrussList getFEMTrussList(IdList ids) throws ServerError;

    /**
     * Gets the FEMTruss object fields.
     *
     * @param id FEMTruss object ID
     * @return FEMTruss object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMTrussFields getFEMTrussFields(long id) throws ServerError;

    /**
     * Gets a list of FEMTruss object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMTruss object IDs
     * @return list of FEMTruss object fields
     */
    idempotent FEMTrussFieldsList getFEMTrussFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMTruss objects matching the given
     * reference fields.
     *
     * @param fields FEMTruss object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMTruss objects
     */
    idempotent IdList findEqualFEMTruss(FEMTrussFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMTruss object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMTruss object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMTrussFields(FEMTrussFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMTruss object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMTrussFieldsList(FEMTrussFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMTimeFunctionData object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMTimeFunctionData(FEMTimeFunctionDataFields fields) throws ServerError;

    /**
     * Adds a set of FEMTimeFunctionData objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMTimeFunctionDataList(FEMTimeFunctionDataFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMTimeFunctionData object.
     *
     * @param id  FEMTimeFunctionData object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMTimeFunctionData(long id) throws ServerError;

    /**
     * Gets the FEMTimeFunctionData object proxy.
     *
     * @param id  FEMTimeFunctionData object ID
     * @return FEMTimeFunctionData object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMTimeFunctionData* getFEMTimeFunctionData(long id) throws ServerError;

    /**
     * Gets a list of all FEMTimeFunctionData object IDs.
     *
     * @return list of FEMTimeFunctionData object IDs
     */
    idempotent IdList getFEMTimeFunctionDataIds() throws ServerError;

    /**
     * Gets a list of FEMTimeFunctionData object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMTimeFunctionData object IDs
     * @return list of FEMTimeFunctionData object proxies
     */
    idempotent FEMTimeFunctionDataList getFEMTimeFunctionDataList(IdList ids) throws ServerError;

    /**
     * Gets the FEMTimeFunctionData object fields.
     *
     * @param id FEMTimeFunctionData object ID
     * @return FEMTimeFunctionData object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMTimeFunctionDataFields getFEMTimeFunctionDataFields(long id) throws ServerError;

    /**
     * Gets a list of FEMTimeFunctionData object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMTimeFunctionData object IDs
     * @return list of FEMTimeFunctionData object fields
     */
    idempotent FEMTimeFunctionDataFieldsList getFEMTimeFunctionDataFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMTimeFunctionData objects matching the given
     * reference fields.
     *
     * @param fields FEMTimeFunctionData object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMTimeFunctionData objects
     */
    idempotent IdList findEqualFEMTimeFunctionData(FEMTimeFunctionDataFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMTimeFunctionData object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMTimeFunctionData object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMTimeFunctionDataFields(FEMTimeFunctionDataFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMTimeFunctionData object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMTimeFunctionDataFieldsList(FEMTimeFunctionDataFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMPlasticMlMaterials object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMPlasticMlMaterials(FEMPlasticMlMaterialsFields fields) throws ServerError;

    /**
     * Adds a set of FEMPlasticMlMaterials objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMPlasticMlMaterialsList(FEMPlasticMlMaterialsFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMPlasticMlMaterials object.
     *
     * @param id  FEMPlasticMlMaterials object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMPlasticMlMaterials(long id) throws ServerError;

    /**
     * Gets the FEMPlasticMlMaterials object proxy.
     *
     * @param id  FEMPlasticMlMaterials object ID
     * @return FEMPlasticMlMaterials object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMPlasticMlMaterials* getFEMPlasticMlMaterials(long id) throws ServerError;

    /**
     * Gets a list of all FEMPlasticMlMaterials object IDs.
     *
     * @return list of FEMPlasticMlMaterials object IDs
     */
    idempotent IdList getFEMPlasticMlMaterialsIds() throws ServerError;

    /**
     * Gets a list of FEMPlasticMlMaterials object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMPlasticMlMaterials object IDs
     * @return list of FEMPlasticMlMaterials object proxies
     */
    idempotent FEMPlasticMlMaterialsList getFEMPlasticMlMaterialsList(IdList ids) throws ServerError;

    /**
     * Gets the FEMPlasticMlMaterials object fields.
     *
     * @param id FEMPlasticMlMaterials object ID
     * @return FEMPlasticMlMaterials object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMPlasticMlMaterialsFields getFEMPlasticMlMaterialsFields(long id) throws ServerError;

    /**
     * Gets a list of FEMPlasticMlMaterials object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMPlasticMlMaterials object IDs
     * @return list of FEMPlasticMlMaterials object fields
     */
    idempotent FEMPlasticMlMaterialsFieldsList getFEMPlasticMlMaterialsFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMPlasticMlMaterials objects matching the given
     * reference fields.
     *
     * @param fields FEMPlasticMlMaterials object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMPlasticMlMaterials objects
     */
    idempotent IdList findEqualFEMPlasticMlMaterials(FEMPlasticMlMaterialsFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMPlasticMlMaterials object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMPlasticMlMaterials object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMPlasticMlMaterialsFields(FEMPlasticMlMaterialsFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMPlasticMlMaterials object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMPlasticMlMaterialsFieldsList(FEMPlasticMlMaterialsFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMPlateGroup object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMPlateGroup(FEMPlateGroupFields fields) throws ServerError;

    /**
     * Adds a set of FEMPlateGroup objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMPlateGroupList(FEMPlateGroupFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMPlateGroup object.
     *
     * @param id  FEMPlateGroup object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMPlateGroup(long id) throws ServerError;

    /**
     * Gets the FEMPlateGroup object proxy.
     *
     * @param id  FEMPlateGroup object ID
     * @return FEMPlateGroup object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMPlateGroup* getFEMPlateGroup(long id) throws ServerError;

    /**
     * Gets a list of all FEMPlateGroup object IDs.
     *
     * @return list of FEMPlateGroup object IDs
     */
    idempotent IdList getFEMPlateGroupIds() throws ServerError;

    /**
     * Gets a list of FEMPlateGroup object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMPlateGroup object IDs
     * @return list of FEMPlateGroup object proxies
     */
    idempotent FEMPlateGroupList getFEMPlateGroupList(IdList ids) throws ServerError;

    /**
     * Gets the FEMPlateGroup object fields.
     *
     * @param id FEMPlateGroup object ID
     * @return FEMPlateGroup object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMPlateGroupFields getFEMPlateGroupFields(long id) throws ServerError;

    /**
     * Gets a list of FEMPlateGroup object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMPlateGroup object IDs
     * @return list of FEMPlateGroup object fields
     */
    idempotent FEMPlateGroupFieldsList getFEMPlateGroupFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMPlateGroup objects matching the given
     * reference fields.
     *
     * @param fields FEMPlateGroup object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMPlateGroup objects
     */
    idempotent IdList findEqualFEMPlateGroup(FEMPlateGroupFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMPlateGroup object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMPlateGroup object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMPlateGroupFields(FEMPlateGroupFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMPlateGroup object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMPlateGroupFieldsList(FEMPlateGroupFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMBeam object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMBeam(FEMBeamFields fields) throws ServerError;

    /**
     * Adds a set of FEMBeam objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMBeamList(FEMBeamFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMBeam object.
     *
     * @param id  FEMBeam object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMBeam(long id) throws ServerError;

    /**
     * Gets the FEMBeam object proxy.
     *
     * @param id  FEMBeam object ID
     * @return FEMBeam object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMBeam* getFEMBeam(long id) throws ServerError;

    /**
     * Gets a list of all FEMBeam object IDs.
     *
     * @return list of FEMBeam object IDs
     */
    idempotent IdList getFEMBeamIds() throws ServerError;

    /**
     * Gets a list of FEMBeam object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMBeam object IDs
     * @return list of FEMBeam object proxies
     */
    idempotent FEMBeamList getFEMBeamList(IdList ids) throws ServerError;

    /**
     * Gets the FEMBeam object fields.
     *
     * @param id FEMBeam object ID
     * @return FEMBeam object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMBeamFields getFEMBeamFields(long id) throws ServerError;

    /**
     * Gets a list of FEMBeam object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMBeam object IDs
     * @return list of FEMBeam object fields
     */
    idempotent FEMBeamFieldsList getFEMBeamFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMBeam objects matching the given
     * reference fields.
     *
     * @param fields FEMBeam object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMBeam objects
     */
    idempotent IdList findEqualFEMBeam(FEMBeamFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMBeam object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMBeam object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMBeamFields(FEMBeamFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMBeam object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMBeamFieldsList(FEMBeamFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMCurvMomentData object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMCurvMomentData(FEMCurvMomentDataFields fields) throws ServerError;

    /**
     * Adds a set of FEMCurvMomentData objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMCurvMomentDataList(FEMCurvMomentDataFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMCurvMomentData object.
     *
     * @param id  FEMCurvMomentData object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMCurvMomentData(long id) throws ServerError;

    /**
     * Gets the FEMCurvMomentData object proxy.
     *
     * @param id  FEMCurvMomentData object ID
     * @return FEMCurvMomentData object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMCurvMomentData* getFEMCurvMomentData(long id) throws ServerError;

    /**
     * Gets a list of all FEMCurvMomentData object IDs.
     *
     * @return list of FEMCurvMomentData object IDs
     */
    idempotent IdList getFEMCurvMomentDataIds() throws ServerError;

    /**
     * Gets a list of FEMCurvMomentData object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMCurvMomentData object IDs
     * @return list of FEMCurvMomentData object proxies
     */
    idempotent FEMCurvMomentDataList getFEMCurvMomentDataList(IdList ids) throws ServerError;

    /**
     * Gets the FEMCurvMomentData object fields.
     *
     * @param id FEMCurvMomentData object ID
     * @return FEMCurvMomentData object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMCurvMomentDataFields getFEMCurvMomentDataFields(long id) throws ServerError;

    /**
     * Gets a list of FEMCurvMomentData object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMCurvMomentData object IDs
     * @return list of FEMCurvMomentData object fields
     */
    idempotent FEMCurvMomentDataFieldsList getFEMCurvMomentDataFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMCurvMomentData objects matching the given
     * reference fields.
     *
     * @param fields FEMCurvMomentData object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMCurvMomentData objects
     */
    idempotent IdList findEqualFEMCurvMomentData(FEMCurvMomentDataFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMCurvMomentData object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMCurvMomentData object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMCurvMomentDataFields(FEMCurvMomentDataFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMCurvMomentData object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMCurvMomentDataFieldsList(FEMCurvMomentDataFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMPropertysets object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMPropertysets(FEMPropertysetsFields fields) throws ServerError;

    /**
     * Adds a set of FEMPropertysets objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMPropertysetsList(FEMPropertysetsFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMPropertysets object.
     *
     * @param id  FEMPropertysets object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMPropertysets(long id) throws ServerError;

    /**
     * Gets the FEMPropertysets object proxy.
     *
     * @param id  FEMPropertysets object ID
     * @return FEMPropertysets object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMPropertysets* getFEMPropertysets(long id) throws ServerError;

    /**
     * Gets a list of all FEMPropertysets object IDs.
     *
     * @return list of FEMPropertysets object IDs
     */
    idempotent IdList getFEMPropertysetsIds() throws ServerError;

    /**
     * Gets a list of FEMPropertysets object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMPropertysets object IDs
     * @return list of FEMPropertysets object proxies
     */
    idempotent FEMPropertysetsList getFEMPropertysetsList(IdList ids) throws ServerError;

    /**
     * Gets the FEMPropertysets object fields.
     *
     * @param id FEMPropertysets object ID
     * @return FEMPropertysets object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMPropertysetsFields getFEMPropertysetsFields(long id) throws ServerError;

    /**
     * Gets a list of FEMPropertysets object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMPropertysets object IDs
     * @return list of FEMPropertysets object fields
     */
    idempotent FEMPropertysetsFieldsList getFEMPropertysetsFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMPropertysets objects matching the given
     * reference fields.
     *
     * @param fields FEMPropertysets object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMPropertysets objects
     */
    idempotent IdList findEqualFEMPropertysets(FEMPropertysetsFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMPropertysets object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMPropertysets object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMPropertysetsFields(FEMPropertysetsFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMPropertysets object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMPropertysetsFieldsList(FEMPropertysetsFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMOrthotropicMaterial object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMOrthotropicMaterial(FEMOrthotropicMaterialFields fields) throws ServerError;

    /**
     * Adds a set of FEMOrthotropicMaterial objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMOrthotropicMaterialList(FEMOrthotropicMaterialFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMOrthotropicMaterial object.
     *
     * @param id  FEMOrthotropicMaterial object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMOrthotropicMaterial(long id) throws ServerError;

    /**
     * Gets the FEMOrthotropicMaterial object proxy.
     *
     * @param id  FEMOrthotropicMaterial object ID
     * @return FEMOrthotropicMaterial object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMOrthotropicMaterial* getFEMOrthotropicMaterial(long id) throws ServerError;

    /**
     * Gets a list of all FEMOrthotropicMaterial object IDs.
     *
     * @return list of FEMOrthotropicMaterial object IDs
     */
    idempotent IdList getFEMOrthotropicMaterialIds() throws ServerError;

    /**
     * Gets a list of FEMOrthotropicMaterial object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMOrthotropicMaterial object IDs
     * @return list of FEMOrthotropicMaterial object proxies
     */
    idempotent FEMOrthotropicMaterialList getFEMOrthotropicMaterialList(IdList ids) throws ServerError;

    /**
     * Gets the FEMOrthotropicMaterial object fields.
     *
     * @param id FEMOrthotropicMaterial object ID
     * @return FEMOrthotropicMaterial object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMOrthotropicMaterialFields getFEMOrthotropicMaterialFields(long id) throws ServerError;

    /**
     * Gets a list of FEMOrthotropicMaterial object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMOrthotropicMaterial object IDs
     * @return list of FEMOrthotropicMaterial object fields
     */
    idempotent FEMOrthotropicMaterialFieldsList getFEMOrthotropicMaterialFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMOrthotropicMaterial objects matching the given
     * reference fields.
     *
     * @param fields FEMOrthotropicMaterial object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMOrthotropicMaterial objects
     */
    idempotent IdList findEqualFEMOrthotropicMaterial(FEMOrthotropicMaterialFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMOrthotropicMaterial object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMOrthotropicMaterial object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMOrthotropicMaterialFields(FEMOrthotropicMaterialFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMOrthotropicMaterial object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMOrthotropicMaterialFieldsList(FEMOrthotropicMaterialFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMAppliedLoads object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMAppliedLoads(FEMAppliedLoadsFields fields) throws ServerError;

    /**
     * Adds a set of FEMAppliedLoads objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMAppliedLoadsList(FEMAppliedLoadsFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMAppliedLoads object.
     *
     * @param id  FEMAppliedLoads object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMAppliedLoads(long id) throws ServerError;

    /**
     * Gets the FEMAppliedLoads object proxy.
     *
     * @param id  FEMAppliedLoads object ID
     * @return FEMAppliedLoads object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMAppliedLoads* getFEMAppliedLoads(long id) throws ServerError;

    /**
     * Gets a list of all FEMAppliedLoads object IDs.
     *
     * @return list of FEMAppliedLoads object IDs
     */
    idempotent IdList getFEMAppliedLoadsIds() throws ServerError;

    /**
     * Gets a list of FEMAppliedLoads object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMAppliedLoads object IDs
     * @return list of FEMAppliedLoads object proxies
     */
    idempotent FEMAppliedLoadsList getFEMAppliedLoadsList(IdList ids) throws ServerError;

    /**
     * Gets the FEMAppliedLoads object fields.
     *
     * @param id FEMAppliedLoads object ID
     * @return FEMAppliedLoads object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMAppliedLoadsFields getFEMAppliedLoadsFields(long id) throws ServerError;

    /**
     * Gets a list of FEMAppliedLoads object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMAppliedLoads object IDs
     * @return list of FEMAppliedLoads object fields
     */
    idempotent FEMAppliedLoadsFieldsList getFEMAppliedLoadsFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMAppliedLoads objects matching the given
     * reference fields.
     *
     * @param fields FEMAppliedLoads object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMAppliedLoads objects
     */
    idempotent IdList findEqualFEMAppliedLoads(FEMAppliedLoadsFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMAppliedLoads object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMAppliedLoads object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMAppliedLoadsFields(FEMAppliedLoadsFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMAppliedLoads object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMAppliedLoadsFieldsList(FEMAppliedLoadsFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMThermoOrthData object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMThermoOrthData(FEMThermoOrthDataFields fields) throws ServerError;

    /**
     * Adds a set of FEMThermoOrthData objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMThermoOrthDataList(FEMThermoOrthDataFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMThermoOrthData object.
     *
     * @param id  FEMThermoOrthData object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMThermoOrthData(long id) throws ServerError;

    /**
     * Gets the FEMThermoOrthData object proxy.
     *
     * @param id  FEMThermoOrthData object ID
     * @return FEMThermoOrthData object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMThermoOrthData* getFEMThermoOrthData(long id) throws ServerError;

    /**
     * Gets a list of all FEMThermoOrthData object IDs.
     *
     * @return list of FEMThermoOrthData object IDs
     */
    idempotent IdList getFEMThermoOrthDataIds() throws ServerError;

    /**
     * Gets a list of FEMThermoOrthData object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMThermoOrthData object IDs
     * @return list of FEMThermoOrthData object proxies
     */
    idempotent FEMThermoOrthDataList getFEMThermoOrthDataList(IdList ids) throws ServerError;

    /**
     * Gets the FEMThermoOrthData object fields.
     *
     * @param id FEMThermoOrthData object ID
     * @return FEMThermoOrthData object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMThermoOrthDataFields getFEMThermoOrthDataFields(long id) throws ServerError;

    /**
     * Gets a list of FEMThermoOrthData object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMThermoOrthData object IDs
     * @return list of FEMThermoOrthData object fields
     */
    idempotent FEMThermoOrthDataFieldsList getFEMThermoOrthDataFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMThermoOrthData objects matching the given
     * reference fields.
     *
     * @param fields FEMThermoOrthData object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMThermoOrthData objects
     */
    idempotent IdList findEqualFEMThermoOrthData(FEMThermoOrthDataFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMThermoOrthData object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMThermoOrthData object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMThermoOrthDataFields(FEMThermoOrthDataFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMThermoOrthData object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMThermoOrthDataFieldsList(FEMThermoOrthDataFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMContactPairs object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMContactPairs(FEMContactPairsFields fields) throws ServerError;

    /**
     * Adds a set of FEMContactPairs objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMContactPairsList(FEMContactPairsFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMContactPairs object.
     *
     * @param id  FEMContactPairs object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMContactPairs(long id) throws ServerError;

    /**
     * Gets the FEMContactPairs object proxy.
     *
     * @param id  FEMContactPairs object ID
     * @return FEMContactPairs object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMContactPairs* getFEMContactPairs(long id) throws ServerError;

    /**
     * Gets a list of all FEMContactPairs object IDs.
     *
     * @return list of FEMContactPairs object IDs
     */
    idempotent IdList getFEMContactPairsIds() throws ServerError;

    /**
     * Gets a list of FEMContactPairs object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMContactPairs object IDs
     * @return list of FEMContactPairs object proxies
     */
    idempotent FEMContactPairsList getFEMContactPairsList(IdList ids) throws ServerError;

    /**
     * Gets the FEMContactPairs object fields.
     *
     * @param id FEMContactPairs object ID
     * @return FEMContactPairs object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMContactPairsFields getFEMContactPairsFields(long id) throws ServerError;

    /**
     * Gets a list of FEMContactPairs object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMContactPairs object IDs
     * @return list of FEMContactPairs object fields
     */
    idempotent FEMContactPairsFieldsList getFEMContactPairsFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMContactPairs objects matching the given
     * reference fields.
     *
     * @param fields FEMContactPairs object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMContactPairs objects
     */
    idempotent IdList findEqualFEMContactPairs(FEMContactPairsFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMContactPairs object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMContactPairs object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMContactPairsFields(FEMContactPairsFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMContactPairs object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMContactPairsFieldsList(FEMContactPairsFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMGeneral object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMGeneral(FEMGeneralFields fields) throws ServerError;

    /**
     * Adds a set of FEMGeneral objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMGeneralList(FEMGeneralFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMGeneral object.
     *
     * @param id  FEMGeneral object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMGeneral(long id) throws ServerError;

    /**
     * Gets the FEMGeneral object proxy.
     *
     * @param id  FEMGeneral object ID
     * @return FEMGeneral object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMGeneral* getFEMGeneral(long id) throws ServerError;

    /**
     * Gets a list of all FEMGeneral object IDs.
     *
     * @return list of FEMGeneral object IDs
     */
    idempotent IdList getFEMGeneralIds() throws ServerError;

    /**
     * Gets a list of FEMGeneral object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMGeneral object IDs
     * @return list of FEMGeneral object proxies
     */
    idempotent FEMGeneralList getFEMGeneralList(IdList ids) throws ServerError;

    /**
     * Gets the FEMGeneral object fields.
     *
     * @param id FEMGeneral object ID
     * @return FEMGeneral object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMGeneralFields getFEMGeneralFields(long id) throws ServerError;

    /**
     * Gets a list of FEMGeneral object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMGeneral object IDs
     * @return list of FEMGeneral object fields
     */
    idempotent FEMGeneralFieldsList getFEMGeneralFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMGeneral objects matching the given
     * reference fields.
     *
     * @param fields FEMGeneral object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMGeneral objects
     */
    idempotent IdList findEqualFEMGeneral(FEMGeneralFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMGeneral object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMGeneral object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMGeneralFields(FEMGeneralFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMGeneral object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMGeneralFieldsList(FEMGeneralFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMBeamGroup object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMBeamGroup(FEMBeamGroupFields fields) throws ServerError;

    /**
     * Adds a set of FEMBeamGroup objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMBeamGroupList(FEMBeamGroupFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMBeamGroup object.
     *
     * @param id  FEMBeamGroup object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMBeamGroup(long id) throws ServerError;

    /**
     * Gets the FEMBeamGroup object proxy.
     *
     * @param id  FEMBeamGroup object ID
     * @return FEMBeamGroup object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMBeamGroup* getFEMBeamGroup(long id) throws ServerError;

    /**
     * Gets a list of all FEMBeamGroup object IDs.
     *
     * @return list of FEMBeamGroup object IDs
     */
    idempotent IdList getFEMBeamGroupIds() throws ServerError;

    /**
     * Gets a list of FEMBeamGroup object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMBeamGroup object IDs
     * @return list of FEMBeamGroup object proxies
     */
    idempotent FEMBeamGroupList getFEMBeamGroupList(IdList ids) throws ServerError;

    /**
     * Gets the FEMBeamGroup object fields.
     *
     * @param id FEMBeamGroup object ID
     * @return FEMBeamGroup object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMBeamGroupFields getFEMBeamGroupFields(long id) throws ServerError;

    /**
     * Gets a list of FEMBeamGroup object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMBeamGroup object IDs
     * @return list of FEMBeamGroup object fields
     */
    idempotent FEMBeamGroupFieldsList getFEMBeamGroupFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMBeamGroup objects matching the given
     * reference fields.
     *
     * @param fields FEMBeamGroup object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMBeamGroup objects
     */
    idempotent IdList findEqualFEMBeamGroup(FEMBeamGroupFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMBeamGroup object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMBeamGroup object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMBeamGroupFields(FEMBeamGroupFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMBeamGroup object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMBeamGroupFieldsList(FEMBeamGroupFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMSectionRect object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMSectionRect(FEMSectionRectFields fields) throws ServerError;

    /**
     * Adds a set of FEMSectionRect objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMSectionRectList(FEMSectionRectFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMSectionRect object.
     *
     * @param id  FEMSectionRect object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMSectionRect(long id) throws ServerError;

    /**
     * Gets the FEMSectionRect object proxy.
     *
     * @param id  FEMSectionRect object ID
     * @return FEMSectionRect object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMSectionRect* getFEMSectionRect(long id) throws ServerError;

    /**
     * Gets a list of all FEMSectionRect object IDs.
     *
     * @return list of FEMSectionRect object IDs
     */
    idempotent IdList getFEMSectionRectIds() throws ServerError;

    /**
     * Gets a list of FEMSectionRect object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMSectionRect object IDs
     * @return list of FEMSectionRect object proxies
     */
    idempotent FEMSectionRectList getFEMSectionRectList(IdList ids) throws ServerError;

    /**
     * Gets the FEMSectionRect object fields.
     *
     * @param id FEMSectionRect object ID
     * @return FEMSectionRect object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMSectionRectFields getFEMSectionRectFields(long id) throws ServerError;

    /**
     * Gets a list of FEMSectionRect object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMSectionRect object IDs
     * @return list of FEMSectionRect object fields
     */
    idempotent FEMSectionRectFieldsList getFEMSectionRectFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMSectionRect objects matching the given
     * reference fields.
     *
     * @param fields FEMSectionRect object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMSectionRect objects
     */
    idempotent IdList findEqualFEMSectionRect(FEMSectionRectFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMSectionRect object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMSectionRect object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMSectionRectFields(FEMSectionRectFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMSectionRect object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMSectionRectFieldsList(FEMSectionRectFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMBeamLoad object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMBeamLoad(FEMBeamLoadFields fields) throws ServerError;

    /**
     * Adds a set of FEMBeamLoad objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMBeamLoadList(FEMBeamLoadFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMBeamLoad object.
     *
     * @param id  FEMBeamLoad object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMBeamLoad(long id) throws ServerError;

    /**
     * Gets the FEMBeamLoad object proxy.
     *
     * @param id  FEMBeamLoad object ID
     * @return FEMBeamLoad object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMBeamLoad* getFEMBeamLoad(long id) throws ServerError;

    /**
     * Gets a list of all FEMBeamLoad object IDs.
     *
     * @return list of FEMBeamLoad object IDs
     */
    idempotent IdList getFEMBeamLoadIds() throws ServerError;

    /**
     * Gets a list of FEMBeamLoad object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMBeamLoad object IDs
     * @return list of FEMBeamLoad object proxies
     */
    idempotent FEMBeamLoadList getFEMBeamLoadList(IdList ids) throws ServerError;

    /**
     * Gets the FEMBeamLoad object fields.
     *
     * @param id FEMBeamLoad object ID
     * @return FEMBeamLoad object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMBeamLoadFields getFEMBeamLoadFields(long id) throws ServerError;

    /**
     * Gets a list of FEMBeamLoad object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMBeamLoad object IDs
     * @return list of FEMBeamLoad object fields
     */
    idempotent FEMBeamLoadFieldsList getFEMBeamLoadFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMBeamLoad objects matching the given
     * reference fields.
     *
     * @param fields FEMBeamLoad object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMBeamLoad objects
     */
    idempotent IdList findEqualFEMBeamLoad(FEMBeamLoadFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMBeamLoad object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMBeamLoad object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMBeamLoadFields(FEMBeamLoadFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMBeamLoad object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMBeamLoadFieldsList(FEMBeamLoadFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMLoadMassProportional object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMLoadMassProportional(FEMLoadMassProportionalFields fields) throws ServerError;

    /**
     * Adds a set of FEMLoadMassProportional objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMLoadMassProportionalList(FEMLoadMassProportionalFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMLoadMassProportional object.
     *
     * @param id  FEMLoadMassProportional object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMLoadMassProportional(long id) throws ServerError;

    /**
     * Gets the FEMLoadMassProportional object proxy.
     *
     * @param id  FEMLoadMassProportional object ID
     * @return FEMLoadMassProportional object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMLoadMassProportional* getFEMLoadMassProportional(long id) throws ServerError;

    /**
     * Gets a list of all FEMLoadMassProportional object IDs.
     *
     * @return list of FEMLoadMassProportional object IDs
     */
    idempotent IdList getFEMLoadMassProportionalIds() throws ServerError;

    /**
     * Gets a list of FEMLoadMassProportional object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMLoadMassProportional object IDs
     * @return list of FEMLoadMassProportional object proxies
     */
    idempotent FEMLoadMassProportionalList getFEMLoadMassProportionalList(IdList ids) throws ServerError;

    /**
     * Gets the FEMLoadMassProportional object fields.
     *
     * @param id FEMLoadMassProportional object ID
     * @return FEMLoadMassProportional object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMLoadMassProportionalFields getFEMLoadMassProportionalFields(long id) throws ServerError;

    /**
     * Gets a list of FEMLoadMassProportional object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMLoadMassProportional object IDs
     * @return list of FEMLoadMassProportional object fields
     */
    idempotent FEMLoadMassProportionalFieldsList getFEMLoadMassProportionalFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMLoadMassProportional objects matching the given
     * reference fields.
     *
     * @param fields FEMLoadMassProportional object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMLoadMassProportional objects
     */
    idempotent IdList findEqualFEMLoadMassProportional(FEMLoadMassProportionalFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMLoadMassProportional object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMLoadMassProportional object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMLoadMassProportionalFields(FEMLoadMassProportionalFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMLoadMassProportional object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMLoadMassProportionalFieldsList(FEMLoadMassProportionalFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMLink object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMLink(FEMLinkFields fields) throws ServerError;

    /**
     * Adds a set of FEMLink objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMLinkList(FEMLinkFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMLink object.
     *
     * @param id  FEMLink object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMLink(long id) throws ServerError;

    /**
     * Gets the FEMLink object proxy.
     *
     * @param id  FEMLink object ID
     * @return FEMLink object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMLink* getFEMLink(long id) throws ServerError;

    /**
     * Gets a list of all FEMLink object IDs.
     *
     * @return list of FEMLink object IDs
     */
    idempotent IdList getFEMLinkIds() throws ServerError;

    /**
     * Gets a list of FEMLink object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMLink object IDs
     * @return list of FEMLink object proxies
     */
    idempotent FEMLinkList getFEMLinkList(IdList ids) throws ServerError;

    /**
     * Gets the FEMLink object fields.
     *
     * @param id FEMLink object ID
     * @return FEMLink object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMLinkFields getFEMLinkFields(long id) throws ServerError;

    /**
     * Gets a list of FEMLink object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMLink object IDs
     * @return list of FEMLink object fields
     */
    idempotent FEMLinkFieldsList getFEMLinkFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMLink objects matching the given
     * reference fields.
     *
     * @param fields FEMLink object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMLink objects
     */
    idempotent IdList findEqualFEMLink(FEMLinkFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMLink object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMLink object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMLinkFields(FEMLinkFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMLink object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMLinkFieldsList(FEMLinkFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMAxesNode object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMAxesNode(FEMAxesNodeFields fields) throws ServerError;

    /**
     * Adds a set of FEMAxesNode objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMAxesNodeList(FEMAxesNodeFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMAxesNode object.
     *
     * @param id  FEMAxesNode object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMAxesNode(long id) throws ServerError;

    /**
     * Gets the FEMAxesNode object proxy.
     *
     * @param id  FEMAxesNode object ID
     * @return FEMAxesNode object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMAxesNode* getFEMAxesNode(long id) throws ServerError;

    /**
     * Gets a list of all FEMAxesNode object IDs.
     *
     * @return list of FEMAxesNode object IDs
     */
    idempotent IdList getFEMAxesNodeIds() throws ServerError;

    /**
     * Gets a list of FEMAxesNode object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMAxesNode object IDs
     * @return list of FEMAxesNode object proxies
     */
    idempotent FEMAxesNodeList getFEMAxesNodeList(IdList ids) throws ServerError;

    /**
     * Gets the FEMAxesNode object fields.
     *
     * @param id FEMAxesNode object ID
     * @return FEMAxesNode object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMAxesNodeFields getFEMAxesNodeFields(long id) throws ServerError;

    /**
     * Gets a list of FEMAxesNode object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMAxesNode object IDs
     * @return list of FEMAxesNode object fields
     */
    idempotent FEMAxesNodeFieldsList getFEMAxesNodeFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMAxesNode objects matching the given
     * reference fields.
     *
     * @param fields FEMAxesNode object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMAxesNode objects
     */
    idempotent IdList findEqualFEMAxesNode(FEMAxesNodeFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMAxesNode object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMAxesNode object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMAxesNodeFields(FEMAxesNodeFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMAxesNode object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMAxesNodeFieldsList(FEMAxesNodeFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMNMTimeMass object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMNMTimeMass(FEMNMTimeMassFields fields) throws ServerError;

    /**
     * Adds a set of FEMNMTimeMass objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMNMTimeMassList(FEMNMTimeMassFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMNMTimeMass object.
     *
     * @param id  FEMNMTimeMass object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMNMTimeMass(long id) throws ServerError;

    /**
     * Gets the FEMNMTimeMass object proxy.
     *
     * @param id  FEMNMTimeMass object ID
     * @return FEMNMTimeMass object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMNMTimeMass* getFEMNMTimeMass(long id) throws ServerError;

    /**
     * Gets a list of all FEMNMTimeMass object IDs.
     *
     * @return list of FEMNMTimeMass object IDs
     */
    idempotent IdList getFEMNMTimeMassIds() throws ServerError;

    /**
     * Gets a list of FEMNMTimeMass object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMNMTimeMass object IDs
     * @return list of FEMNMTimeMass object proxies
     */
    idempotent FEMNMTimeMassList getFEMNMTimeMassList(IdList ids) throws ServerError;

    /**
     * Gets the FEMNMTimeMass object fields.
     *
     * @param id FEMNMTimeMass object ID
     * @return FEMNMTimeMass object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMNMTimeMassFields getFEMNMTimeMassFields(long id) throws ServerError;

    /**
     * Gets a list of FEMNMTimeMass object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMNMTimeMass object IDs
     * @return list of FEMNMTimeMass object fields
     */
    idempotent FEMNMTimeMassFieldsList getFEMNMTimeMassFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMNMTimeMass objects matching the given
     * reference fields.
     *
     * @param fields FEMNMTimeMass object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMNMTimeMass objects
     */
    idempotent IdList findEqualFEMNMTimeMass(FEMNMTimeMassFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMNMTimeMass object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMNMTimeMass object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMNMTimeMassFields(FEMNMTimeMassFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMNMTimeMass object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMNMTimeMassFieldsList(FEMNMTimeMassFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMAppliedDisplacement object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMAppliedDisplacement(FEMAppliedDisplacementFields fields) throws ServerError;

    /**
     * Adds a set of FEMAppliedDisplacement objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMAppliedDisplacementList(FEMAppliedDisplacementFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMAppliedDisplacement object.
     *
     * @param id  FEMAppliedDisplacement object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMAppliedDisplacement(long id) throws ServerError;

    /**
     * Gets the FEMAppliedDisplacement object proxy.
     *
     * @param id  FEMAppliedDisplacement object ID
     * @return FEMAppliedDisplacement object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMAppliedDisplacement* getFEMAppliedDisplacement(long id) throws ServerError;

    /**
     * Gets a list of all FEMAppliedDisplacement object IDs.
     *
     * @return list of FEMAppliedDisplacement object IDs
     */
    idempotent IdList getFEMAppliedDisplacementIds() throws ServerError;

    /**
     * Gets a list of FEMAppliedDisplacement object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMAppliedDisplacement object IDs
     * @return list of FEMAppliedDisplacement object proxies
     */
    idempotent FEMAppliedDisplacementList getFEMAppliedDisplacementList(IdList ids) throws ServerError;

    /**
     * Gets the FEMAppliedDisplacement object fields.
     *
     * @param id FEMAppliedDisplacement object ID
     * @return FEMAppliedDisplacement object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMAppliedDisplacementFields getFEMAppliedDisplacementFields(long id) throws ServerError;

    /**
     * Gets a list of FEMAppliedDisplacement object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMAppliedDisplacement object IDs
     * @return list of FEMAppliedDisplacement object fields
     */
    idempotent FEMAppliedDisplacementFieldsList getFEMAppliedDisplacementFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMAppliedDisplacement objects matching the given
     * reference fields.
     *
     * @param fields FEMAppliedDisplacement object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMAppliedDisplacement objects
     */
    idempotent IdList findEqualFEMAppliedDisplacement(FEMAppliedDisplacementFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMAppliedDisplacement object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMAppliedDisplacement object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMAppliedDisplacementFields(FEMAppliedDisplacementFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMAppliedDisplacement object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMAppliedDisplacementFieldsList(FEMAppliedDisplacementFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMTimeFunctions object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMTimeFunctions(FEMTimeFunctionsFields fields) throws ServerError;

    /**
     * Adds a set of FEMTimeFunctions objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMTimeFunctionsList(FEMTimeFunctionsFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMTimeFunctions object.
     *
     * @param id  FEMTimeFunctions object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMTimeFunctions(long id) throws ServerError;

    /**
     * Gets the FEMTimeFunctions object proxy.
     *
     * @param id  FEMTimeFunctions object ID
     * @return FEMTimeFunctions object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMTimeFunctions* getFEMTimeFunctions(long id) throws ServerError;

    /**
     * Gets a list of all FEMTimeFunctions object IDs.
     *
     * @return list of FEMTimeFunctions object IDs
     */
    idempotent IdList getFEMTimeFunctionsIds() throws ServerError;

    /**
     * Gets a list of FEMTimeFunctions object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMTimeFunctions object IDs
     * @return list of FEMTimeFunctions object proxies
     */
    idempotent FEMTimeFunctionsList getFEMTimeFunctionsList(IdList ids) throws ServerError;

    /**
     * Gets the FEMTimeFunctions object fields.
     *
     * @param id FEMTimeFunctions object ID
     * @return FEMTimeFunctions object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMTimeFunctionsFields getFEMTimeFunctionsFields(long id) throws ServerError;

    /**
     * Gets a list of FEMTimeFunctions object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMTimeFunctions object IDs
     * @return list of FEMTimeFunctions object fields
     */
    idempotent FEMTimeFunctionsFieldsList getFEMTimeFunctionsFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMTimeFunctions objects matching the given
     * reference fields.
     *
     * @param fields FEMTimeFunctions object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMTimeFunctions objects
     */
    idempotent IdList findEqualFEMTimeFunctions(FEMTimeFunctionsFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMTimeFunctions object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMTimeFunctions object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMTimeFunctionsFields(FEMTimeFunctionsFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMTimeFunctions object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMTimeFunctionsFieldsList(FEMTimeFunctionsFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMForceStrainData object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMForceStrainData(FEMForceStrainDataFields fields) throws ServerError;

    /**
     * Adds a set of FEMForceStrainData objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMForceStrainDataList(FEMForceStrainDataFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMForceStrainData object.
     *
     * @param id  FEMForceStrainData object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMForceStrainData(long id) throws ServerError;

    /**
     * Gets the FEMForceStrainData object proxy.
     *
     * @param id  FEMForceStrainData object ID
     * @return FEMForceStrainData object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMForceStrainData* getFEMForceStrainData(long id) throws ServerError;

    /**
     * Gets a list of all FEMForceStrainData object IDs.
     *
     * @return list of FEMForceStrainData object IDs
     */
    idempotent IdList getFEMForceStrainDataIds() throws ServerError;

    /**
     * Gets a list of FEMForceStrainData object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMForceStrainData object IDs
     * @return list of FEMForceStrainData object proxies
     */
    idempotent FEMForceStrainDataList getFEMForceStrainDataList(IdList ids) throws ServerError;

    /**
     * Gets the FEMForceStrainData object fields.
     *
     * @param id FEMForceStrainData object ID
     * @return FEMForceStrainData object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMForceStrainDataFields getFEMForceStrainDataFields(long id) throws ServerError;

    /**
     * Gets a list of FEMForceStrainData object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMForceStrainData object IDs
     * @return list of FEMForceStrainData object fields
     */
    idempotent FEMForceStrainDataFieldsList getFEMForceStrainDataFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMForceStrainData objects matching the given
     * reference fields.
     *
     * @param fields FEMForceStrainData object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMForceStrainData objects
     */
    idempotent IdList findEqualFEMForceStrainData(FEMForceStrainDataFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMForceStrainData object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMForceStrainData object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMForceStrainDataFields(FEMForceStrainDataFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMForceStrainData object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMForceStrainDataFieldsList(FEMForceStrainDataFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMSkewDOF object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMSkewDOF(FEMSkewDOFFields fields) throws ServerError;

    /**
     * Adds a set of FEMSkewDOF objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMSkewDOFList(FEMSkewDOFFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMSkewDOF object.
     *
     * @param id  FEMSkewDOF object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMSkewDOF(long id) throws ServerError;

    /**
     * Gets the FEMSkewDOF object proxy.
     *
     * @param id  FEMSkewDOF object ID
     * @return FEMSkewDOF object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMSkewDOF* getFEMSkewDOF(long id) throws ServerError;

    /**
     * Gets a list of all FEMSkewDOF object IDs.
     *
     * @return list of FEMSkewDOF object IDs
     */
    idempotent IdList getFEMSkewDOFIds() throws ServerError;

    /**
     * Gets a list of FEMSkewDOF object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMSkewDOF object IDs
     * @return list of FEMSkewDOF object proxies
     */
    idempotent FEMSkewDOFList getFEMSkewDOFList(IdList ids) throws ServerError;

    /**
     * Gets the FEMSkewDOF object fields.
     *
     * @param id FEMSkewDOF object ID
     * @return FEMSkewDOF object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMSkewDOFFields getFEMSkewDOFFields(long id) throws ServerError;

    /**
     * Gets a list of FEMSkewDOF object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMSkewDOF object IDs
     * @return list of FEMSkewDOF object fields
     */
    idempotent FEMSkewDOFFieldsList getFEMSkewDOFFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMSkewDOF objects matching the given
     * reference fields.
     *
     * @param fields FEMSkewDOF object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMSkewDOF objects
     */
    idempotent IdList findEqualFEMSkewDOF(FEMSkewDOFFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMSkewDOF object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMSkewDOF object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMSkewDOFFields(FEMSkewDOFFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMSkewDOF object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMSkewDOFFieldsList(FEMSkewDOFFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMSectionI object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMSectionI(FEMSectionIFields fields) throws ServerError;

    /**
     * Adds a set of FEMSectionI objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMSectionIList(FEMSectionIFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMSectionI object.
     *
     * @param id  FEMSectionI object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMSectionI(long id) throws ServerError;

    /**
     * Gets the FEMSectionI object proxy.
     *
     * @param id  FEMSectionI object ID
     * @return FEMSectionI object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMSectionI* getFEMSectionI(long id) throws ServerError;

    /**
     * Gets a list of all FEMSectionI object IDs.
     *
     * @return list of FEMSectionI object IDs
     */
    idempotent IdList getFEMSectionIIds() throws ServerError;

    /**
     * Gets a list of FEMSectionI object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMSectionI object IDs
     * @return list of FEMSectionI object proxies
     */
    idempotent FEMSectionIList getFEMSectionIList(IdList ids) throws ServerError;

    /**
     * Gets the FEMSectionI object fields.
     *
     * @param id FEMSectionI object ID
     * @return FEMSectionI object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMSectionIFields getFEMSectionIFields(long id) throws ServerError;

    /**
     * Gets a list of FEMSectionI object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMSectionI object IDs
     * @return list of FEMSectionI object fields
     */
    idempotent FEMSectionIFieldsList getFEMSectionIFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMSectionI objects matching the given
     * reference fields.
     *
     * @param fields FEMSectionI object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMSectionI objects
     */
    idempotent IdList findEqualFEMSectionI(FEMSectionIFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMSectionI object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMSectionI object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMSectionIFields(FEMSectionIFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMSectionI object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMSectionIFieldsList(FEMSectionIFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMPlasticBilinearMaterial object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMPlasticBilinearMaterial(FEMPlasticBilinearMaterialFields fields) throws ServerError;

    /**
     * Adds a set of FEMPlasticBilinearMaterial objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMPlasticBilinearMaterialList(FEMPlasticBilinearMaterialFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMPlasticBilinearMaterial object.
     *
     * @param id  FEMPlasticBilinearMaterial object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMPlasticBilinearMaterial(long id) throws ServerError;

    /**
     * Gets the FEMPlasticBilinearMaterial object proxy.
     *
     * @param id  FEMPlasticBilinearMaterial object ID
     * @return FEMPlasticBilinearMaterial object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMPlasticBilinearMaterial* getFEMPlasticBilinearMaterial(long id) throws ServerError;

    /**
     * Gets a list of all FEMPlasticBilinearMaterial object IDs.
     *
     * @return list of FEMPlasticBilinearMaterial object IDs
     */
    idempotent IdList getFEMPlasticBilinearMaterialIds() throws ServerError;

    /**
     * Gets a list of FEMPlasticBilinearMaterial object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMPlasticBilinearMaterial object IDs
     * @return list of FEMPlasticBilinearMaterial object proxies
     */
    idempotent FEMPlasticBilinearMaterialList getFEMPlasticBilinearMaterialList(IdList ids) throws ServerError;

    /**
     * Gets the FEMPlasticBilinearMaterial object fields.
     *
     * @param id FEMPlasticBilinearMaterial object ID
     * @return FEMPlasticBilinearMaterial object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMPlasticBilinearMaterialFields getFEMPlasticBilinearMaterialFields(long id) throws ServerError;

    /**
     * Gets a list of FEMPlasticBilinearMaterial object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMPlasticBilinearMaterial object IDs
     * @return list of FEMPlasticBilinearMaterial object fields
     */
    idempotent FEMPlasticBilinearMaterialFieldsList getFEMPlasticBilinearMaterialFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMPlasticBilinearMaterial objects matching the given
     * reference fields.
     *
     * @param fields FEMPlasticBilinearMaterial object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMPlasticBilinearMaterial objects
     */
    idempotent IdList findEqualFEMPlasticBilinearMaterial(FEMPlasticBilinearMaterialFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMPlasticBilinearMaterial object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMPlasticBilinearMaterial object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMPlasticBilinearMaterialFields(FEMPlasticBilinearMaterialFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMPlasticBilinearMaterial object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMPlasticBilinearMaterialFieldsList(FEMPlasticBilinearMaterialFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMMTForceData object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMMTForceData(FEMMTForceDataFields fields) throws ServerError;

    /**
     * Adds a set of FEMMTForceData objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMMTForceDataList(FEMMTForceDataFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMMTForceData object.
     *
     * @param id  FEMMTForceData object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMMTForceData(long id) throws ServerError;

    /**
     * Gets the FEMMTForceData object proxy.
     *
     * @param id  FEMMTForceData object ID
     * @return FEMMTForceData object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMMTForceData* getFEMMTForceData(long id) throws ServerError;

    /**
     * Gets a list of all FEMMTForceData object IDs.
     *
     * @return list of FEMMTForceData object IDs
     */
    idempotent IdList getFEMMTForceDataIds() throws ServerError;

    /**
     * Gets a list of FEMMTForceData object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMMTForceData object IDs
     * @return list of FEMMTForceData object proxies
     */
    idempotent FEMMTForceDataList getFEMMTForceDataList(IdList ids) throws ServerError;

    /**
     * Gets the FEMMTForceData object fields.
     *
     * @param id FEMMTForceData object ID
     * @return FEMMTForceData object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMMTForceDataFields getFEMMTForceDataFields(long id) throws ServerError;

    /**
     * Gets a list of FEMMTForceData object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMMTForceData object IDs
     * @return list of FEMMTForceData object fields
     */
    idempotent FEMMTForceDataFieldsList getFEMMTForceDataFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMMTForceData objects matching the given
     * reference fields.
     *
     * @param fields FEMMTForceData object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMMTForceData objects
     */
    idempotent IdList findEqualFEMMTForceData(FEMMTForceDataFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMMTForceData object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMMTForceData object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMMTForceDataFields(FEMMTForceDataFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMMTForceData object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMMTForceDataFieldsList(FEMMTForceDataFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMShellPressure object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMShellPressure(FEMShellPressureFields fields) throws ServerError;

    /**
     * Adds a set of FEMShellPressure objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMShellPressureList(FEMShellPressureFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMShellPressure object.
     *
     * @param id  FEMShellPressure object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMShellPressure(long id) throws ServerError;

    /**
     * Gets the FEMShellPressure object proxy.
     *
     * @param id  FEMShellPressure object ID
     * @return FEMShellPressure object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMShellPressure* getFEMShellPressure(long id) throws ServerError;

    /**
     * Gets a list of all FEMShellPressure object IDs.
     *
     * @return list of FEMShellPressure object IDs
     */
    idempotent IdList getFEMShellPressureIds() throws ServerError;

    /**
     * Gets a list of FEMShellPressure object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMShellPressure object IDs
     * @return list of FEMShellPressure object proxies
     */
    idempotent FEMShellPressureList getFEMShellPressureList(IdList ids) throws ServerError;

    /**
     * Gets the FEMShellPressure object fields.
     *
     * @param id FEMShellPressure object ID
     * @return FEMShellPressure object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMShellPressureFields getFEMShellPressureFields(long id) throws ServerError;

    /**
     * Gets a list of FEMShellPressure object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMShellPressure object IDs
     * @return list of FEMShellPressure object fields
     */
    idempotent FEMShellPressureFieldsList getFEMShellPressureFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMShellPressure objects matching the given
     * reference fields.
     *
     * @param fields FEMShellPressure object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMShellPressure objects
     */
    idempotent IdList findEqualFEMShellPressure(FEMShellPressureFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMShellPressure object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMShellPressure object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMShellPressureFields(FEMShellPressureFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMShellPressure object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMShellPressureFieldsList(FEMShellPressureFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMMatrices object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMMatrices(FEMMatricesFields fields) throws ServerError;

    /**
     * Adds a set of FEMMatrices objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMMatricesList(FEMMatricesFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMMatrices object.
     *
     * @param id  FEMMatrices object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMMatrices(long id) throws ServerError;

    /**
     * Gets the FEMMatrices object proxy.
     *
     * @param id  FEMMatrices object ID
     * @return FEMMatrices object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMMatrices* getFEMMatrices(long id) throws ServerError;

    /**
     * Gets a list of all FEMMatrices object IDs.
     *
     * @return list of FEMMatrices object IDs
     */
    idempotent IdList getFEMMatricesIds() throws ServerError;

    /**
     * Gets a list of FEMMatrices object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMMatrices object IDs
     * @return list of FEMMatrices object proxies
     */
    idempotent FEMMatricesList getFEMMatricesList(IdList ids) throws ServerError;

    /**
     * Gets the FEMMatrices object fields.
     *
     * @param id FEMMatrices object ID
     * @return FEMMatrices object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMMatricesFields getFEMMatricesFields(long id) throws ServerError;

    /**
     * Gets a list of FEMMatrices object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMMatrices object IDs
     * @return list of FEMMatrices object fields
     */
    idempotent FEMMatricesFieldsList getFEMMatricesFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMMatrices objects matching the given
     * reference fields.
     *
     * @param fields FEMMatrices object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMMatrices objects
     */
    idempotent IdList findEqualFEMMatrices(FEMMatricesFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMMatrices object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMMatrices object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMMatricesFields(FEMMatricesFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMMatrices object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMMatricesFieldsList(FEMMatricesFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMDamping object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMDamping(FEMDampingFields fields) throws ServerError;

    /**
     * Adds a set of FEMDamping objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMDampingList(FEMDampingFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMDamping object.
     *
     * @param id  FEMDamping object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMDamping(long id) throws ServerError;

    /**
     * Gets the FEMDamping object proxy.
     *
     * @param id  FEMDamping object ID
     * @return FEMDamping object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMDamping* getFEMDamping(long id) throws ServerError;

    /**
     * Gets a list of all FEMDamping object IDs.
     *
     * @return list of FEMDamping object IDs
     */
    idempotent IdList getFEMDampingIds() throws ServerError;

    /**
     * Gets a list of FEMDamping object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMDamping object IDs
     * @return list of FEMDamping object proxies
     */
    idempotent FEMDampingList getFEMDampingList(IdList ids) throws ServerError;

    /**
     * Gets the FEMDamping object fields.
     *
     * @param id FEMDamping object ID
     * @return FEMDamping object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMDampingFields getFEMDampingFields(long id) throws ServerError;

    /**
     * Gets a list of FEMDamping object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMDamping object IDs
     * @return list of FEMDamping object fields
     */
    idempotent FEMDampingFieldsList getFEMDampingFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMDamping objects matching the given
     * reference fields.
     *
     * @param fields FEMDamping object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMDamping objects
     */
    idempotent IdList findEqualFEMDamping(FEMDampingFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMDamping object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMDamping object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMDampingFields(FEMDampingFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMDamping object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMDampingFieldsList(FEMDampingFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMMaterial object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMMaterial(FEMMaterialFields fields) throws ServerError;

    /**
     * Adds a set of FEMMaterial objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMMaterialList(FEMMaterialFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMMaterial object.
     *
     * @param id  FEMMaterial object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMMaterial(long id) throws ServerError;

    /**
     * Gets the FEMMaterial object proxy.
     *
     * @param id  FEMMaterial object ID
     * @return FEMMaterial object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMMaterial* getFEMMaterial(long id) throws ServerError;

    /**
     * Gets a list of all FEMMaterial object IDs.
     *
     * @return list of FEMMaterial object IDs
     */
    idempotent IdList getFEMMaterialIds() throws ServerError;

    /**
     * Gets a list of FEMMaterial object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMMaterial object IDs
     * @return list of FEMMaterial object proxies
     */
    idempotent FEMMaterialList getFEMMaterialList(IdList ids) throws ServerError;

    /**
     * Gets the FEMMaterial object fields.
     *
     * @param id FEMMaterial object ID
     * @return FEMMaterial object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMMaterialFields getFEMMaterialFields(long id) throws ServerError;

    /**
     * Gets a list of FEMMaterial object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMMaterial object IDs
     * @return list of FEMMaterial object fields
     */
    idempotent FEMMaterialFieldsList getFEMMaterialFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMMaterial objects matching the given
     * reference fields.
     *
     * @param fields FEMMaterial object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMMaterial objects
     */
    idempotent IdList findEqualFEMMaterial(FEMMaterialFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMMaterial object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMMaterial object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMMaterialFields(FEMMaterialFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMMaterial object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMMaterialFieldsList(FEMMaterialFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMMatrixData object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMMatrixData(FEMMatrixDataFields fields) throws ServerError;

    /**
     * Adds a set of FEMMatrixData objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMMatrixDataList(FEMMatrixDataFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMMatrixData object.
     *
     * @param id  FEMMatrixData object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMMatrixData(long id) throws ServerError;

    /**
     * Gets the FEMMatrixData object proxy.
     *
     * @param id  FEMMatrixData object ID
     * @return FEMMatrixData object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMMatrixData* getFEMMatrixData(long id) throws ServerError;

    /**
     * Gets a list of all FEMMatrixData object IDs.
     *
     * @return list of FEMMatrixData object IDs
     */
    idempotent IdList getFEMMatrixDataIds() throws ServerError;

    /**
     * Gets a list of FEMMatrixData object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMMatrixData object IDs
     * @return list of FEMMatrixData object proxies
     */
    idempotent FEMMatrixDataList getFEMMatrixDataList(IdList ids) throws ServerError;

    /**
     * Gets the FEMMatrixData object fields.
     *
     * @param id FEMMatrixData object ID
     * @return FEMMatrixData object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMMatrixDataFields getFEMMatrixDataFields(long id) throws ServerError;

    /**
     * Gets a list of FEMMatrixData object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMMatrixData object IDs
     * @return list of FEMMatrixData object fields
     */
    idempotent FEMMatrixDataFieldsList getFEMMatrixDataFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMMatrixData objects matching the given
     * reference fields.
     *
     * @param fields FEMMatrixData object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMMatrixData objects
     */
    idempotent IdList findEqualFEMMatrixData(FEMMatrixDataFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMMatrixData object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMMatrixData object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMMatrixDataFields(FEMMatrixDataFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMMatrixData object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMMatrixDataFieldsList(FEMMatrixDataFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMShellAxesOrtho object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMShellAxesOrtho(FEMShellAxesOrthoFields fields) throws ServerError;

    /**
     * Adds a set of FEMShellAxesOrtho objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMShellAxesOrthoList(FEMShellAxesOrthoFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMShellAxesOrtho object.
     *
     * @param id  FEMShellAxesOrtho object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMShellAxesOrtho(long id) throws ServerError;

    /**
     * Gets the FEMShellAxesOrtho object proxy.
     *
     * @param id  FEMShellAxesOrtho object ID
     * @return FEMShellAxesOrtho object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMShellAxesOrtho* getFEMShellAxesOrtho(long id) throws ServerError;

    /**
     * Gets a list of all FEMShellAxesOrtho object IDs.
     *
     * @return list of FEMShellAxesOrtho object IDs
     */
    idempotent IdList getFEMShellAxesOrthoIds() throws ServerError;

    /**
     * Gets a list of FEMShellAxesOrtho object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMShellAxesOrtho object IDs
     * @return list of FEMShellAxesOrtho object proxies
     */
    idempotent FEMShellAxesOrthoList getFEMShellAxesOrthoList(IdList ids) throws ServerError;

    /**
     * Gets the FEMShellAxesOrtho object fields.
     *
     * @param id FEMShellAxesOrtho object ID
     * @return FEMShellAxesOrtho object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMShellAxesOrthoFields getFEMShellAxesOrthoFields(long id) throws ServerError;

    /**
     * Gets a list of FEMShellAxesOrtho object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMShellAxesOrtho object IDs
     * @return list of FEMShellAxesOrtho object fields
     */
    idempotent FEMShellAxesOrthoFieldsList getFEMShellAxesOrthoFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMShellAxesOrtho objects matching the given
     * reference fields.
     *
     * @param fields FEMShellAxesOrtho object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMShellAxesOrtho objects
     */
    idempotent IdList findEqualFEMShellAxesOrtho(FEMShellAxesOrthoFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMShellAxesOrtho object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMShellAxesOrtho object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMShellAxesOrthoFields(FEMShellAxesOrthoFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMShellAxesOrtho object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMShellAxesOrthoFieldsList(FEMShellAxesOrthoFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMEndRelease object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMEndRelease(FEMEndReleaseFields fields) throws ServerError;

    /**
     * Adds a set of FEMEndRelease objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMEndReleaseList(FEMEndReleaseFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMEndRelease object.
     *
     * @param id  FEMEndRelease object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMEndRelease(long id) throws ServerError;

    /**
     * Gets the FEMEndRelease object proxy.
     *
     * @param id  FEMEndRelease object ID
     * @return FEMEndRelease object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMEndRelease* getFEMEndRelease(long id) throws ServerError;

    /**
     * Gets a list of all FEMEndRelease object IDs.
     *
     * @return list of FEMEndRelease object IDs
     */
    idempotent IdList getFEMEndReleaseIds() throws ServerError;

    /**
     * Gets a list of FEMEndRelease object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMEndRelease object IDs
     * @return list of FEMEndRelease object proxies
     */
    idempotent FEMEndReleaseList getFEMEndReleaseList(IdList ids) throws ServerError;

    /**
     * Gets the FEMEndRelease object fields.
     *
     * @param id FEMEndRelease object ID
     * @return FEMEndRelease object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMEndReleaseFields getFEMEndReleaseFields(long id) throws ServerError;

    /**
     * Gets a list of FEMEndRelease object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMEndRelease object IDs
     * @return list of FEMEndRelease object fields
     */
    idempotent FEMEndReleaseFieldsList getFEMEndReleaseFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMEndRelease objects matching the given
     * reference fields.
     *
     * @param fields FEMEndRelease object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMEndRelease objects
     */
    idempotent IdList findEqualFEMEndRelease(FEMEndReleaseFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMEndRelease object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMEndRelease object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMEndReleaseFields(FEMEndReleaseFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMEndRelease object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMEndReleaseFieldsList(FEMEndReleaseFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMTrussGroup object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMTrussGroup(FEMTrussGroupFields fields) throws ServerError;

    /**
     * Adds a set of FEMTrussGroup objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMTrussGroupList(FEMTrussGroupFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMTrussGroup object.
     *
     * @param id  FEMTrussGroup object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMTrussGroup(long id) throws ServerError;

    /**
     * Gets the FEMTrussGroup object proxy.
     *
     * @param id  FEMTrussGroup object ID
     * @return FEMTrussGroup object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMTrussGroup* getFEMTrussGroup(long id) throws ServerError;

    /**
     * Gets a list of all FEMTrussGroup object IDs.
     *
     * @return list of FEMTrussGroup object IDs
     */
    idempotent IdList getFEMTrussGroupIds() throws ServerError;

    /**
     * Gets a list of FEMTrussGroup object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMTrussGroup object IDs
     * @return list of FEMTrussGroup object proxies
     */
    idempotent FEMTrussGroupList getFEMTrussGroupList(IdList ids) throws ServerError;

    /**
     * Gets the FEMTrussGroup object fields.
     *
     * @param id FEMTrussGroup object ID
     * @return FEMTrussGroup object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMTrussGroupFields getFEMTrussGroupFields(long id) throws ServerError;

    /**
     * Gets a list of FEMTrussGroup object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMTrussGroup object IDs
     * @return list of FEMTrussGroup object fields
     */
    idempotent FEMTrussGroupFieldsList getFEMTrussGroupFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMTrussGroup objects matching the given
     * reference fields.
     *
     * @param fields FEMTrussGroup object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMTrussGroup objects
     */
    idempotent IdList findEqualFEMTrussGroup(FEMTrussGroupFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMTrussGroup object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMTrussGroup object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMTrussGroupFields(FEMTrussGroupFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMTrussGroup object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMTrussGroupFieldsList(FEMTrussGroupFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMInitialTemperature object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMInitialTemperature(FEMInitialTemperatureFields fields) throws ServerError;

    /**
     * Adds a set of FEMInitialTemperature objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMInitialTemperatureList(FEMInitialTemperatureFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMInitialTemperature object.
     *
     * @param id  FEMInitialTemperature object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMInitialTemperature(long id) throws ServerError;

    /**
     * Gets the FEMInitialTemperature object proxy.
     *
     * @param id  FEMInitialTemperature object ID
     * @return FEMInitialTemperature object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMInitialTemperature* getFEMInitialTemperature(long id) throws ServerError;

    /**
     * Gets a list of all FEMInitialTemperature object IDs.
     *
     * @return list of FEMInitialTemperature object IDs
     */
    idempotent IdList getFEMInitialTemperatureIds() throws ServerError;

    /**
     * Gets a list of FEMInitialTemperature object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMInitialTemperature object IDs
     * @return list of FEMInitialTemperature object proxies
     */
    idempotent FEMInitialTemperatureList getFEMInitialTemperatureList(IdList ids) throws ServerError;

    /**
     * Gets the FEMInitialTemperature object fields.
     *
     * @param id FEMInitialTemperature object ID
     * @return FEMInitialTemperature object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMInitialTemperatureFields getFEMInitialTemperatureFields(long id) throws ServerError;

    /**
     * Gets a list of FEMInitialTemperature object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMInitialTemperature object IDs
     * @return list of FEMInitialTemperature object fields
     */
    idempotent FEMInitialTemperatureFieldsList getFEMInitialTemperatureFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMInitialTemperature objects matching the given
     * reference fields.
     *
     * @param fields FEMInitialTemperature object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMInitialTemperature objects
     */
    idempotent IdList findEqualFEMInitialTemperature(FEMInitialTemperatureFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMInitialTemperature object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMInitialTemperature object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMInitialTemperatureFields(FEMInitialTemperatureFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMInitialTemperature object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMInitialTemperatureFieldsList(FEMInitialTemperatureFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMThermoIsoMaterials object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMThermoIsoMaterials(FEMThermoIsoMaterialsFields fields) throws ServerError;

    /**
     * Adds a set of FEMThermoIsoMaterials objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMThermoIsoMaterialsList(FEMThermoIsoMaterialsFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMThermoIsoMaterials object.
     *
     * @param id  FEMThermoIsoMaterials object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMThermoIsoMaterials(long id) throws ServerError;

    /**
     * Gets the FEMThermoIsoMaterials object proxy.
     *
     * @param id  FEMThermoIsoMaterials object ID
     * @return FEMThermoIsoMaterials object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMThermoIsoMaterials* getFEMThermoIsoMaterials(long id) throws ServerError;

    /**
     * Gets a list of all FEMThermoIsoMaterials object IDs.
     *
     * @return list of FEMThermoIsoMaterials object IDs
     */
    idempotent IdList getFEMThermoIsoMaterialsIds() throws ServerError;

    /**
     * Gets a list of FEMThermoIsoMaterials object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMThermoIsoMaterials object IDs
     * @return list of FEMThermoIsoMaterials object proxies
     */
    idempotent FEMThermoIsoMaterialsList getFEMThermoIsoMaterialsList(IdList ids) throws ServerError;

    /**
     * Gets the FEMThermoIsoMaterials object fields.
     *
     * @param id FEMThermoIsoMaterials object ID
     * @return FEMThermoIsoMaterials object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMThermoIsoMaterialsFields getFEMThermoIsoMaterialsFields(long id) throws ServerError;

    /**
     * Gets a list of FEMThermoIsoMaterials object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMThermoIsoMaterials object IDs
     * @return list of FEMThermoIsoMaterials object fields
     */
    idempotent FEMThermoIsoMaterialsFieldsList getFEMThermoIsoMaterialsFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMThermoIsoMaterials objects matching the given
     * reference fields.
     *
     * @param fields FEMThermoIsoMaterials object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMThermoIsoMaterials objects
     */
    idempotent IdList findEqualFEMThermoIsoMaterials(FEMThermoIsoMaterialsFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMThermoIsoMaterials object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMThermoIsoMaterials object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMThermoIsoMaterialsFields(FEMThermoIsoMaterialsFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMThermoIsoMaterials object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMThermoIsoMaterialsFieldsList(FEMThermoIsoMaterialsFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMThermoIsoData object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMThermoIsoData(FEMThermoIsoDataFields fields) throws ServerError;

    /**
     * Adds a set of FEMThermoIsoData objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMThermoIsoDataList(FEMThermoIsoDataFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMThermoIsoData object.
     *
     * @param id  FEMThermoIsoData object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMThermoIsoData(long id) throws ServerError;

    /**
     * Gets the FEMThermoIsoData object proxy.
     *
     * @param id  FEMThermoIsoData object ID
     * @return FEMThermoIsoData object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMThermoIsoData* getFEMThermoIsoData(long id) throws ServerError;

    /**
     * Gets a list of all FEMThermoIsoData object IDs.
     *
     * @return list of FEMThermoIsoData object IDs
     */
    idempotent IdList getFEMThermoIsoDataIds() throws ServerError;

    /**
     * Gets a list of FEMThermoIsoData object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMThermoIsoData object IDs
     * @return list of FEMThermoIsoData object proxies
     */
    idempotent FEMThermoIsoDataList getFEMThermoIsoDataList(IdList ids) throws ServerError;

    /**
     * Gets the FEMThermoIsoData object fields.
     *
     * @param id FEMThermoIsoData object ID
     * @return FEMThermoIsoData object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMThermoIsoDataFields getFEMThermoIsoDataFields(long id) throws ServerError;

    /**
     * Gets a list of FEMThermoIsoData object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMThermoIsoData object IDs
     * @return list of FEMThermoIsoData object fields
     */
    idempotent FEMThermoIsoDataFieldsList getFEMThermoIsoDataFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMThermoIsoData objects matching the given
     * reference fields.
     *
     * @param fields FEMThermoIsoData object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMThermoIsoData objects
     */
    idempotent IdList findEqualFEMThermoIsoData(FEMThermoIsoDataFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMThermoIsoData object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMThermoIsoData object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMThermoIsoDataFields(FEMThermoIsoDataFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMThermoIsoData object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMThermoIsoDataFieldsList(FEMThermoIsoDataFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMContactGroup3 object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMContactGroup3(FEMContactGroup3Fields fields) throws ServerError;

    /**
     * Adds a set of FEMContactGroup3 objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMContactGroup3List(FEMContactGroup3FieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMContactGroup3 object.
     *
     * @param id  FEMContactGroup3 object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMContactGroup3(long id) throws ServerError;

    /**
     * Gets the FEMContactGroup3 object proxy.
     *
     * @param id  FEMContactGroup3 object ID
     * @return FEMContactGroup3 object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMContactGroup3* getFEMContactGroup3(long id) throws ServerError;

    /**
     * Gets a list of all FEMContactGroup3 object IDs.
     *
     * @return list of FEMContactGroup3 object IDs
     */
    idempotent IdList getFEMContactGroup3Ids() throws ServerError;

    /**
     * Gets a list of FEMContactGroup3 object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMContactGroup3 object IDs
     * @return list of FEMContactGroup3 object proxies
     */
    idempotent FEMContactGroup3List getFEMContactGroup3List(IdList ids) throws ServerError;

    /**
     * Gets the FEMContactGroup3 object fields.
     *
     * @param id FEMContactGroup3 object ID
     * @return FEMContactGroup3 object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMContactGroup3Fields getFEMContactGroup3Fields(long id) throws ServerError;

    /**
     * Gets a list of FEMContactGroup3 object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMContactGroup3 object IDs
     * @return list of FEMContactGroup3 object fields
     */
    idempotent FEMContactGroup3FieldsList getFEMContactGroup3FieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMContactGroup3 objects matching the given
     * reference fields.
     *
     * @param fields FEMContactGroup3 object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMContactGroup3 objects
     */
    idempotent IdList findEqualFEMContactGroup3(FEMContactGroup3Fields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMContactGroup3 object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMContactGroup3 object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMContactGroup3Fields(FEMContactGroup3Fields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMContactGroup3 object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMContactGroup3FieldsList(FEMContactGroup3FieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMNLElasticMaterials object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMNLElasticMaterials(FEMNLElasticMaterialsFields fields) throws ServerError;

    /**
     * Adds a set of FEMNLElasticMaterials objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMNLElasticMaterialsList(FEMNLElasticMaterialsFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMNLElasticMaterials object.
     *
     * @param id  FEMNLElasticMaterials object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMNLElasticMaterials(long id) throws ServerError;

    /**
     * Gets the FEMNLElasticMaterials object proxy.
     *
     * @param id  FEMNLElasticMaterials object ID
     * @return FEMNLElasticMaterials object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMNLElasticMaterials* getFEMNLElasticMaterials(long id) throws ServerError;

    /**
     * Gets a list of all FEMNLElasticMaterials object IDs.
     *
     * @return list of FEMNLElasticMaterials object IDs
     */
    idempotent IdList getFEMNLElasticMaterialsIds() throws ServerError;

    /**
     * Gets a list of FEMNLElasticMaterials object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMNLElasticMaterials object IDs
     * @return list of FEMNLElasticMaterials object proxies
     */
    idempotent FEMNLElasticMaterialsList getFEMNLElasticMaterialsList(IdList ids) throws ServerError;

    /**
     * Gets the FEMNLElasticMaterials object fields.
     *
     * @param id FEMNLElasticMaterials object ID
     * @return FEMNLElasticMaterials object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMNLElasticMaterialsFields getFEMNLElasticMaterialsFields(long id) throws ServerError;

    /**
     * Gets a list of FEMNLElasticMaterials object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMNLElasticMaterials object IDs
     * @return list of FEMNLElasticMaterials object fields
     */
    idempotent FEMNLElasticMaterialsFieldsList getFEMNLElasticMaterialsFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMNLElasticMaterials objects matching the given
     * reference fields.
     *
     * @param fields FEMNLElasticMaterials object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMNLElasticMaterials objects
     */
    idempotent IdList findEqualFEMNLElasticMaterials(FEMNLElasticMaterialsFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMNLElasticMaterials object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMNLElasticMaterials object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMNLElasticMaterialsFields(FEMNLElasticMaterialsFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMNLElasticMaterials object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMNLElasticMaterialsFieldsList(FEMNLElasticMaterialsFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMPlate object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMPlate(FEMPlateFields fields) throws ServerError;

    /**
     * Adds a set of FEMPlate objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMPlateList(FEMPlateFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMPlate object.
     *
     * @param id  FEMPlate object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMPlate(long id) throws ServerError;

    /**
     * Gets the FEMPlate object proxy.
     *
     * @param id  FEMPlate object ID
     * @return FEMPlate object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMPlate* getFEMPlate(long id) throws ServerError;

    /**
     * Gets a list of all FEMPlate object IDs.
     *
     * @return list of FEMPlate object IDs
     */
    idempotent IdList getFEMPlateIds() throws ServerError;

    /**
     * Gets a list of FEMPlate object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMPlate object IDs
     * @return list of FEMPlate object proxies
     */
    idempotent FEMPlateList getFEMPlateList(IdList ids) throws ServerError;

    /**
     * Gets the FEMPlate object fields.
     *
     * @param id FEMPlate object ID
     * @return FEMPlate object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMPlateFields getFEMPlateFields(long id) throws ServerError;

    /**
     * Gets a list of FEMPlate object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMPlate object IDs
     * @return list of FEMPlate object fields
     */
    idempotent FEMPlateFieldsList getFEMPlateFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMPlate objects matching the given
     * reference fields.
     *
     * @param fields FEMPlate object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMPlate objects
     */
    idempotent IdList findEqualFEMPlate(FEMPlateFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMPlate object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMPlate object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMPlateFields(FEMPlateFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMPlate object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMPlateFieldsList(FEMPlateFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMIsoBeam object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMIsoBeam(FEMIsoBeamFields fields) throws ServerError;

    /**
     * Adds a set of FEMIsoBeam objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMIsoBeamList(FEMIsoBeamFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMIsoBeam object.
     *
     * @param id  FEMIsoBeam object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMIsoBeam(long id) throws ServerError;

    /**
     * Gets the FEMIsoBeam object proxy.
     *
     * @param id  FEMIsoBeam object ID
     * @return FEMIsoBeam object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMIsoBeam* getFEMIsoBeam(long id) throws ServerError;

    /**
     * Gets a list of all FEMIsoBeam object IDs.
     *
     * @return list of FEMIsoBeam object IDs
     */
    idempotent IdList getFEMIsoBeamIds() throws ServerError;

    /**
     * Gets a list of FEMIsoBeam object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMIsoBeam object IDs
     * @return list of FEMIsoBeam object proxies
     */
    idempotent FEMIsoBeamList getFEMIsoBeamList(IdList ids) throws ServerError;

    /**
     * Gets the FEMIsoBeam object fields.
     *
     * @param id FEMIsoBeam object ID
     * @return FEMIsoBeam object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMIsoBeamFields getFEMIsoBeamFields(long id) throws ServerError;

    /**
     * Gets a list of FEMIsoBeam object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMIsoBeam object IDs
     * @return list of FEMIsoBeam object fields
     */
    idempotent FEMIsoBeamFieldsList getFEMIsoBeamFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMIsoBeam objects matching the given
     * reference fields.
     *
     * @param fields FEMIsoBeam object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMIsoBeam objects
     */
    idempotent IdList findEqualFEMIsoBeam(FEMIsoBeamFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMIsoBeam object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMIsoBeam object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMIsoBeamFields(FEMIsoBeamFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMIsoBeam object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMIsoBeamFieldsList(FEMIsoBeamFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMAppliedConcentratedLoad object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMAppliedConcentratedLoad(FEMAppliedConcentratedLoadFields fields) throws ServerError;

    /**
     * Adds a set of FEMAppliedConcentratedLoad objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMAppliedConcentratedLoadList(FEMAppliedConcentratedLoadFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMAppliedConcentratedLoad object.
     *
     * @param id  FEMAppliedConcentratedLoad object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMAppliedConcentratedLoad(long id) throws ServerError;

    /**
     * Gets the FEMAppliedConcentratedLoad object proxy.
     *
     * @param id  FEMAppliedConcentratedLoad object ID
     * @return FEMAppliedConcentratedLoad object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMAppliedConcentratedLoad* getFEMAppliedConcentratedLoad(long id) throws ServerError;

    /**
     * Gets a list of all FEMAppliedConcentratedLoad object IDs.
     *
     * @return list of FEMAppliedConcentratedLoad object IDs
     */
    idempotent IdList getFEMAppliedConcentratedLoadIds() throws ServerError;

    /**
     * Gets a list of FEMAppliedConcentratedLoad object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMAppliedConcentratedLoad object IDs
     * @return list of FEMAppliedConcentratedLoad object proxies
     */
    idempotent FEMAppliedConcentratedLoadList getFEMAppliedConcentratedLoadList(IdList ids) throws ServerError;

    /**
     * Gets the FEMAppliedConcentratedLoad object fields.
     *
     * @param id FEMAppliedConcentratedLoad object ID
     * @return FEMAppliedConcentratedLoad object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMAppliedConcentratedLoadFields getFEMAppliedConcentratedLoadFields(long id) throws ServerError;

    /**
     * Gets a list of FEMAppliedConcentratedLoad object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMAppliedConcentratedLoad object IDs
     * @return list of FEMAppliedConcentratedLoad object fields
     */
    idempotent FEMAppliedConcentratedLoadFieldsList getFEMAppliedConcentratedLoadFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMAppliedConcentratedLoad objects matching the given
     * reference fields.
     *
     * @param fields FEMAppliedConcentratedLoad object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMAppliedConcentratedLoad objects
     */
    idempotent IdList findEqualFEMAppliedConcentratedLoad(FEMAppliedConcentratedLoadFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMAppliedConcentratedLoad object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMAppliedConcentratedLoad object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMAppliedConcentratedLoadFields(FEMAppliedConcentratedLoadFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMAppliedConcentratedLoad object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMAppliedConcentratedLoadFieldsList(FEMAppliedConcentratedLoadFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMTwoDSolidGroup object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMTwoDSolidGroup(FEMTwoDSolidGroupFields fields) throws ServerError;

    /**
     * Adds a set of FEMTwoDSolidGroup objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMTwoDSolidGroupList(FEMTwoDSolidGroupFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMTwoDSolidGroup object.
     *
     * @param id  FEMTwoDSolidGroup object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMTwoDSolidGroup(long id) throws ServerError;

    /**
     * Gets the FEMTwoDSolidGroup object proxy.
     *
     * @param id  FEMTwoDSolidGroup object ID
     * @return FEMTwoDSolidGroup object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMTwoDSolidGroup* getFEMTwoDSolidGroup(long id) throws ServerError;

    /**
     * Gets a list of all FEMTwoDSolidGroup object IDs.
     *
     * @return list of FEMTwoDSolidGroup object IDs
     */
    idempotent IdList getFEMTwoDSolidGroupIds() throws ServerError;

    /**
     * Gets a list of FEMTwoDSolidGroup object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMTwoDSolidGroup object IDs
     * @return list of FEMTwoDSolidGroup object proxies
     */
    idempotent FEMTwoDSolidGroupList getFEMTwoDSolidGroupList(IdList ids) throws ServerError;

    /**
     * Gets the FEMTwoDSolidGroup object fields.
     *
     * @param id FEMTwoDSolidGroup object ID
     * @return FEMTwoDSolidGroup object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMTwoDSolidGroupFields getFEMTwoDSolidGroupFields(long id) throws ServerError;

    /**
     * Gets a list of FEMTwoDSolidGroup object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMTwoDSolidGroup object IDs
     * @return list of FEMTwoDSolidGroup object fields
     */
    idempotent FEMTwoDSolidGroupFieldsList getFEMTwoDSolidGroupFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMTwoDSolidGroup objects matching the given
     * reference fields.
     *
     * @param fields FEMTwoDSolidGroup object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMTwoDSolidGroup objects
     */
    idempotent IdList findEqualFEMTwoDSolidGroup(FEMTwoDSolidGroupFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMTwoDSolidGroup object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMTwoDSolidGroup object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMTwoDSolidGroupFields(FEMTwoDSolidGroupFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMTwoDSolidGroup object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMTwoDSolidGroupFieldsList(FEMTwoDSolidGroupFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMGroup object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMGroup(FEMGroupFields fields) throws ServerError;

    /**
     * Adds a set of FEMGroup objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMGroupList(FEMGroupFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMGroup object.
     *
     * @param id  FEMGroup object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMGroup(long id) throws ServerError;

    /**
     * Gets the FEMGroup object proxy.
     *
     * @param id  FEMGroup object ID
     * @return FEMGroup object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMGroup* getFEMGroup(long id) throws ServerError;

    /**
     * Gets a list of all FEMGroup object IDs.
     *
     * @return list of FEMGroup object IDs
     */
    idempotent IdList getFEMGroupIds() throws ServerError;

    /**
     * Gets a list of FEMGroup object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMGroup object IDs
     * @return list of FEMGroup object proxies
     */
    idempotent FEMGroupList getFEMGroupList(IdList ids) throws ServerError;

    /**
     * Gets the FEMGroup object fields.
     *
     * @param id FEMGroup object ID
     * @return FEMGroup object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMGroupFields getFEMGroupFields(long id) throws ServerError;

    /**
     * Gets a list of FEMGroup object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMGroup object IDs
     * @return list of FEMGroup object fields
     */
    idempotent FEMGroupFieldsList getFEMGroupFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMGroup objects matching the given
     * reference fields.
     *
     * @param fields FEMGroup object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMGroup objects
     */
    idempotent IdList findEqualFEMGroup(FEMGroupFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMGroup object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMGroup object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMGroupFields(FEMGroupFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMGroup object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMGroupFieldsList(FEMGroupFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMProperties object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMProperties(FEMPropertiesFields fields) throws ServerError;

    /**
     * Adds a set of FEMProperties objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMPropertiesList(FEMPropertiesFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMProperties object.
     *
     * @param id  FEMProperties object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMProperties(long id) throws ServerError;

    /**
     * Gets the FEMProperties object proxy.
     *
     * @param id  FEMProperties object ID
     * @return FEMProperties object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMProperties* getFEMProperties(long id) throws ServerError;

    /**
     * Gets a list of all FEMProperties object IDs.
     *
     * @return list of FEMProperties object IDs
     */
    idempotent IdList getFEMPropertiesIds() throws ServerError;

    /**
     * Gets a list of FEMProperties object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMProperties object IDs
     * @return list of FEMProperties object proxies
     */
    idempotent FEMPropertiesList getFEMPropertiesList(IdList ids) throws ServerError;

    /**
     * Gets the FEMProperties object fields.
     *
     * @param id FEMProperties object ID
     * @return FEMProperties object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMPropertiesFields getFEMPropertiesFields(long id) throws ServerError;

    /**
     * Gets a list of FEMProperties object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMProperties object IDs
     * @return list of FEMProperties object fields
     */
    idempotent FEMPropertiesFieldsList getFEMPropertiesFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMProperties objects matching the given
     * reference fields.
     *
     * @param fields FEMProperties object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMProperties objects
     */
    idempotent IdList findEqualFEMProperties(FEMPropertiesFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMProperties object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMProperties object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMPropertiesFields(FEMPropertiesFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMProperties object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMPropertiesFieldsList(FEMPropertiesFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMThreeDSolidGroup object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMThreeDSolidGroup(FEMThreeDSolidGroupFields fields) throws ServerError;

    /**
     * Adds a set of FEMThreeDSolidGroup objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMThreeDSolidGroupList(FEMThreeDSolidGroupFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMThreeDSolidGroup object.
     *
     * @param id  FEMThreeDSolidGroup object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMThreeDSolidGroup(long id) throws ServerError;

    /**
     * Gets the FEMThreeDSolidGroup object proxy.
     *
     * @param id  FEMThreeDSolidGroup object ID
     * @return FEMThreeDSolidGroup object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMThreeDSolidGroup* getFEMThreeDSolidGroup(long id) throws ServerError;

    /**
     * Gets a list of all FEMThreeDSolidGroup object IDs.
     *
     * @return list of FEMThreeDSolidGroup object IDs
     */
    idempotent IdList getFEMThreeDSolidGroupIds() throws ServerError;

    /**
     * Gets a list of FEMThreeDSolidGroup object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMThreeDSolidGroup object IDs
     * @return list of FEMThreeDSolidGroup object proxies
     */
    idempotent FEMThreeDSolidGroupList getFEMThreeDSolidGroupList(IdList ids) throws ServerError;

    /**
     * Gets the FEMThreeDSolidGroup object fields.
     *
     * @param id FEMThreeDSolidGroup object ID
     * @return FEMThreeDSolidGroup object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMThreeDSolidGroupFields getFEMThreeDSolidGroupFields(long id) throws ServerError;

    /**
     * Gets a list of FEMThreeDSolidGroup object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMThreeDSolidGroup object IDs
     * @return list of FEMThreeDSolidGroup object fields
     */
    idempotent FEMThreeDSolidGroupFieldsList getFEMThreeDSolidGroupFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMThreeDSolidGroup objects matching the given
     * reference fields.
     *
     * @param fields FEMThreeDSolidGroup object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMThreeDSolidGroup objects
     */
    idempotent IdList findEqualFEMThreeDSolidGroup(FEMThreeDSolidGroupFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMThreeDSolidGroup object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMThreeDSolidGroup object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMThreeDSolidGroupFields(FEMThreeDSolidGroupFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMThreeDSolidGroup object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMThreeDSolidGroupFieldsList(FEMThreeDSolidGroupFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMThreeDSolid object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMThreeDSolid(FEMThreeDSolidFields fields) throws ServerError;

    /**
     * Adds a set of FEMThreeDSolid objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMThreeDSolidList(FEMThreeDSolidFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMThreeDSolid object.
     *
     * @param id  FEMThreeDSolid object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMThreeDSolid(long id) throws ServerError;

    /**
     * Gets the FEMThreeDSolid object proxy.
     *
     * @param id  FEMThreeDSolid object ID
     * @return FEMThreeDSolid object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMThreeDSolid* getFEMThreeDSolid(long id) throws ServerError;

    /**
     * Gets a list of all FEMThreeDSolid object IDs.
     *
     * @return list of FEMThreeDSolid object IDs
     */
    idempotent IdList getFEMThreeDSolidIds() throws ServerError;

    /**
     * Gets a list of FEMThreeDSolid object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMThreeDSolid object IDs
     * @return list of FEMThreeDSolid object proxies
     */
    idempotent FEMThreeDSolidList getFEMThreeDSolidList(IdList ids) throws ServerError;

    /**
     * Gets the FEMThreeDSolid object fields.
     *
     * @param id FEMThreeDSolid object ID
     * @return FEMThreeDSolid object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMThreeDSolidFields getFEMThreeDSolidFields(long id) throws ServerError;

    /**
     * Gets a list of FEMThreeDSolid object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMThreeDSolid object IDs
     * @return list of FEMThreeDSolid object fields
     */
    idempotent FEMThreeDSolidFieldsList getFEMThreeDSolidFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMThreeDSolid objects matching the given
     * reference fields.
     *
     * @param fields FEMThreeDSolid object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMThreeDSolid objects
     */
    idempotent IdList findEqualFEMThreeDSolid(FEMThreeDSolidFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMThreeDSolid object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMThreeDSolid object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMThreeDSolidFields(FEMThreeDSolidFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMThreeDSolid object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMThreeDSolidFieldsList(FEMThreeDSolidFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMSectionProp object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMSectionProp(FEMSectionPropFields fields) throws ServerError;

    /**
     * Adds a set of FEMSectionProp objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMSectionPropList(FEMSectionPropFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMSectionProp object.
     *
     * @param id  FEMSectionProp object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMSectionProp(long id) throws ServerError;

    /**
     * Gets the FEMSectionProp object proxy.
     *
     * @param id  FEMSectionProp object ID
     * @return FEMSectionProp object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMSectionProp* getFEMSectionProp(long id) throws ServerError;

    /**
     * Gets a list of all FEMSectionProp object IDs.
     *
     * @return list of FEMSectionProp object IDs
     */
    idempotent IdList getFEMSectionPropIds() throws ServerError;

    /**
     * Gets a list of FEMSectionProp object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMSectionProp object IDs
     * @return list of FEMSectionProp object proxies
     */
    idempotent FEMSectionPropList getFEMSectionPropList(IdList ids) throws ServerError;

    /**
     * Gets the FEMSectionProp object fields.
     *
     * @param id FEMSectionProp object ID
     * @return FEMSectionProp object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMSectionPropFields getFEMSectionPropFields(long id) throws ServerError;

    /**
     * Gets a list of FEMSectionProp object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMSectionProp object IDs
     * @return list of FEMSectionProp object fields
     */
    idempotent FEMSectionPropFieldsList getFEMSectionPropFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMSectionProp objects matching the given
     * reference fields.
     *
     * @param fields FEMSectionProp object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMSectionProp objects
     */
    idempotent IdList findEqualFEMSectionProp(FEMSectionPropFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMSectionProp object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMSectionProp object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMSectionPropFields(FEMSectionPropFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMSectionProp object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMSectionPropFieldsList(FEMSectionPropFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMElasticMaterial object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMElasticMaterial(FEMElasticMaterialFields fields) throws ServerError;

    /**
     * Adds a set of FEMElasticMaterial objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMElasticMaterialList(FEMElasticMaterialFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMElasticMaterial object.
     *
     * @param id  FEMElasticMaterial object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMElasticMaterial(long id) throws ServerError;

    /**
     * Gets the FEMElasticMaterial object proxy.
     *
     * @param id  FEMElasticMaterial object ID
     * @return FEMElasticMaterial object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMElasticMaterial* getFEMElasticMaterial(long id) throws ServerError;

    /**
     * Gets a list of all FEMElasticMaterial object IDs.
     *
     * @return list of FEMElasticMaterial object IDs
     */
    idempotent IdList getFEMElasticMaterialIds() throws ServerError;

    /**
     * Gets a list of FEMElasticMaterial object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMElasticMaterial object IDs
     * @return list of FEMElasticMaterial object proxies
     */
    idempotent FEMElasticMaterialList getFEMElasticMaterialList(IdList ids) throws ServerError;

    /**
     * Gets the FEMElasticMaterial object fields.
     *
     * @param id FEMElasticMaterial object ID
     * @return FEMElasticMaterial object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMElasticMaterialFields getFEMElasticMaterialFields(long id) throws ServerError;

    /**
     * Gets a list of FEMElasticMaterial object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMElasticMaterial object IDs
     * @return list of FEMElasticMaterial object fields
     */
    idempotent FEMElasticMaterialFieldsList getFEMElasticMaterialFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMElasticMaterial objects matching the given
     * reference fields.
     *
     * @param fields FEMElasticMaterial object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMElasticMaterial objects
     */
    idempotent IdList findEqualFEMElasticMaterial(FEMElasticMaterialFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMElasticMaterial object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMElasticMaterial object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMElasticMaterialFields(FEMElasticMaterialFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMElasticMaterial object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMElasticMaterialFieldsList(FEMElasticMaterialFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMPoints object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMPoints(FEMPointsFields fields) throws ServerError;

    /**
     * Adds a set of FEMPoints objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMPointsList(FEMPointsFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMPoints object.
     *
     * @param id  FEMPoints object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMPoints(long id) throws ServerError;

    /**
     * Gets the FEMPoints object proxy.
     *
     * @param id  FEMPoints object ID
     * @return FEMPoints object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMPoints* getFEMPoints(long id) throws ServerError;

    /**
     * Gets a list of all FEMPoints object IDs.
     *
     * @return list of FEMPoints object IDs
     */
    idempotent IdList getFEMPointsIds() throws ServerError;

    /**
     * Gets a list of FEMPoints object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMPoints object IDs
     * @return list of FEMPoints object proxies
     */
    idempotent FEMPointsList getFEMPointsList(IdList ids) throws ServerError;

    /**
     * Gets the FEMPoints object fields.
     *
     * @param id FEMPoints object ID
     * @return FEMPoints object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMPointsFields getFEMPointsFields(long id) throws ServerError;

    /**
     * Gets a list of FEMPoints object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMPoints object IDs
     * @return list of FEMPoints object fields
     */
    idempotent FEMPointsFieldsList getFEMPointsFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMPoints objects matching the given
     * reference fields.
     *
     * @param fields FEMPoints object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMPoints objects
     */
    idempotent IdList findEqualFEMPoints(FEMPointsFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMPoints object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMPoints object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMPointsFields(FEMPointsFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMPoints object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMPointsFieldsList(FEMPointsFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMThermoOrthMaterials object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMThermoOrthMaterials(FEMThermoOrthMaterialsFields fields) throws ServerError;

    /**
     * Adds a set of FEMThermoOrthMaterials objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMThermoOrthMaterialsList(FEMThermoOrthMaterialsFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMThermoOrthMaterials object.
     *
     * @param id  FEMThermoOrthMaterials object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMThermoOrthMaterials(long id) throws ServerError;

    /**
     * Gets the FEMThermoOrthMaterials object proxy.
     *
     * @param id  FEMThermoOrthMaterials object ID
     * @return FEMThermoOrthMaterials object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMThermoOrthMaterials* getFEMThermoOrthMaterials(long id) throws ServerError;

    /**
     * Gets a list of all FEMThermoOrthMaterials object IDs.
     *
     * @return list of FEMThermoOrthMaterials object IDs
     */
    idempotent IdList getFEMThermoOrthMaterialsIds() throws ServerError;

    /**
     * Gets a list of FEMThermoOrthMaterials object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMThermoOrthMaterials object IDs
     * @return list of FEMThermoOrthMaterials object proxies
     */
    idempotent FEMThermoOrthMaterialsList getFEMThermoOrthMaterialsList(IdList ids) throws ServerError;

    /**
     * Gets the FEMThermoOrthMaterials object fields.
     *
     * @param id FEMThermoOrthMaterials object ID
     * @return FEMThermoOrthMaterials object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMThermoOrthMaterialsFields getFEMThermoOrthMaterialsFields(long id) throws ServerError;

    /**
     * Gets a list of FEMThermoOrthMaterials object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMThermoOrthMaterials object IDs
     * @return list of FEMThermoOrthMaterials object fields
     */
    idempotent FEMThermoOrthMaterialsFieldsList getFEMThermoOrthMaterialsFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMThermoOrthMaterials objects matching the given
     * reference fields.
     *
     * @param fields FEMThermoOrthMaterials object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMThermoOrthMaterials objects
     */
    idempotent IdList findEqualFEMThermoOrthMaterials(FEMThermoOrthMaterialsFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMThermoOrthMaterials object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMThermoOrthMaterials object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMThermoOrthMaterialsFields(FEMThermoOrthMaterialsFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMThermoOrthMaterials object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMThermoOrthMaterialsFieldsList(FEMThermoOrthMaterialsFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMConstraints object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMConstraints(FEMConstraintsFields fields) throws ServerError;

    /**
     * Adds a set of FEMConstraints objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMConstraintsList(FEMConstraintsFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMConstraints object.
     *
     * @param id  FEMConstraints object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMConstraints(long id) throws ServerError;

    /**
     * Gets the FEMConstraints object proxy.
     *
     * @param id  FEMConstraints object ID
     * @return FEMConstraints object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMConstraints* getFEMConstraints(long id) throws ServerError;

    /**
     * Gets a list of all FEMConstraints object IDs.
     *
     * @return list of FEMConstraints object IDs
     */
    idempotent IdList getFEMConstraintsIds() throws ServerError;

    /**
     * Gets a list of FEMConstraints object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMConstraints object IDs
     * @return list of FEMConstraints object proxies
     */
    idempotent FEMConstraintsList getFEMConstraintsList(IdList ids) throws ServerError;

    /**
     * Gets the FEMConstraints object fields.
     *
     * @param id FEMConstraints object ID
     * @return FEMConstraints object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMConstraintsFields getFEMConstraintsFields(long id) throws ServerError;

    /**
     * Gets a list of FEMConstraints object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMConstraints object IDs
     * @return list of FEMConstraints object fields
     */
    idempotent FEMConstraintsFieldsList getFEMConstraintsFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMConstraints objects matching the given
     * reference fields.
     *
     * @param fields FEMConstraints object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMConstraints objects
     */
    idempotent IdList findEqualFEMConstraints(FEMConstraintsFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMConstraints object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMConstraints object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMConstraintsFields(FEMConstraintsFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMConstraints object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMConstraintsFieldsList(FEMConstraintsFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMMCrigidities object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMMCrigidities(FEMMCrigiditiesFields fields) throws ServerError;

    /**
     * Adds a set of FEMMCrigidities objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMMCrigiditiesList(FEMMCrigiditiesFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMMCrigidities object.
     *
     * @param id  FEMMCrigidities object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMMCrigidities(long id) throws ServerError;

    /**
     * Gets the FEMMCrigidities object proxy.
     *
     * @param id  FEMMCrigidities object ID
     * @return FEMMCrigidities object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMMCrigidities* getFEMMCrigidities(long id) throws ServerError;

    /**
     * Gets a list of all FEMMCrigidities object IDs.
     *
     * @return list of FEMMCrigidities object IDs
     */
    idempotent IdList getFEMMCrigiditiesIds() throws ServerError;

    /**
     * Gets a list of FEMMCrigidities object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMMCrigidities object IDs
     * @return list of FEMMCrigidities object proxies
     */
    idempotent FEMMCrigiditiesList getFEMMCrigiditiesList(IdList ids) throws ServerError;

    /**
     * Gets the FEMMCrigidities object fields.
     *
     * @param id FEMMCrigidities object ID
     * @return FEMMCrigidities object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMMCrigiditiesFields getFEMMCrigiditiesFields(long id) throws ServerError;

    /**
     * Gets a list of FEMMCrigidities object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMMCrigidities object IDs
     * @return list of FEMMCrigidities object fields
     */
    idempotent FEMMCrigiditiesFieldsList getFEMMCrigiditiesFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMMCrigidities objects matching the given
     * reference fields.
     *
     * @param fields FEMMCrigidities object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMMCrigidities objects
     */
    idempotent IdList findEqualFEMMCrigidities(FEMMCrigiditiesFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMMCrigidities object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMMCrigidities object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMMCrigiditiesFields(FEMMCrigiditiesFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMMCrigidities object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMMCrigiditiesFieldsList(FEMMCrigiditiesFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMSkeySysNode object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMSkeySysNode(FEMSkeySysNodeFields fields) throws ServerError;

    /**
     * Adds a set of FEMSkeySysNode objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMSkeySysNodeList(FEMSkeySysNodeFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMSkeySysNode object.
     *
     * @param id  FEMSkeySysNode object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMSkeySysNode(long id) throws ServerError;

    /**
     * Gets the FEMSkeySysNode object proxy.
     *
     * @param id  FEMSkeySysNode object ID
     * @return FEMSkeySysNode object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMSkeySysNode* getFEMSkeySysNode(long id) throws ServerError;

    /**
     * Gets a list of all FEMSkeySysNode object IDs.
     *
     * @return list of FEMSkeySysNode object IDs
     */
    idempotent IdList getFEMSkeySysNodeIds() throws ServerError;

    /**
     * Gets a list of FEMSkeySysNode object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMSkeySysNode object IDs
     * @return list of FEMSkeySysNode object proxies
     */
    idempotent FEMSkeySysNodeList getFEMSkeySysNodeList(IdList ids) throws ServerError;

    /**
     * Gets the FEMSkeySysNode object fields.
     *
     * @param id FEMSkeySysNode object ID
     * @return FEMSkeySysNode object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMSkeySysNodeFields getFEMSkeySysNodeFields(long id) throws ServerError;

    /**
     * Gets a list of FEMSkeySysNode object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMSkeySysNode object IDs
     * @return list of FEMSkeySysNode object fields
     */
    idempotent FEMSkeySysNodeFieldsList getFEMSkeySysNodeFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMSkeySysNode objects matching the given
     * reference fields.
     *
     * @param fields FEMSkeySysNode object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMSkeySysNode objects
     */
    idempotent IdList findEqualFEMSkeySysNode(FEMSkeySysNodeFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMSkeySysNode object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMSkeySysNode object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMSkeySysNodeFields(FEMSkeySysNodeFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMSkeySysNode object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMSkeySysNodeFieldsList(FEMSkeySysNodeFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMIsoBeamGroup object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMIsoBeamGroup(FEMIsoBeamGroupFields fields) throws ServerError;

    /**
     * Adds a set of FEMIsoBeamGroup objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMIsoBeamGroupList(FEMIsoBeamGroupFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMIsoBeamGroup object.
     *
     * @param id  FEMIsoBeamGroup object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMIsoBeamGroup(long id) throws ServerError;

    /**
     * Gets the FEMIsoBeamGroup object proxy.
     *
     * @param id  FEMIsoBeamGroup object ID
     * @return FEMIsoBeamGroup object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMIsoBeamGroup* getFEMIsoBeamGroup(long id) throws ServerError;

    /**
     * Gets a list of all FEMIsoBeamGroup object IDs.
     *
     * @return list of FEMIsoBeamGroup object IDs
     */
    idempotent IdList getFEMIsoBeamGroupIds() throws ServerError;

    /**
     * Gets a list of FEMIsoBeamGroup object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMIsoBeamGroup object IDs
     * @return list of FEMIsoBeamGroup object proxies
     */
    idempotent FEMIsoBeamGroupList getFEMIsoBeamGroupList(IdList ids) throws ServerError;

    /**
     * Gets the FEMIsoBeamGroup object fields.
     *
     * @param id FEMIsoBeamGroup object ID
     * @return FEMIsoBeamGroup object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMIsoBeamGroupFields getFEMIsoBeamGroupFields(long id) throws ServerError;

    /**
     * Gets a list of FEMIsoBeamGroup object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMIsoBeamGroup object IDs
     * @return list of FEMIsoBeamGroup object fields
     */
    idempotent FEMIsoBeamGroupFieldsList getFEMIsoBeamGroupFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMIsoBeamGroup objects matching the given
     * reference fields.
     *
     * @param fields FEMIsoBeamGroup object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMIsoBeamGroup objects
     */
    idempotent IdList findEqualFEMIsoBeamGroup(FEMIsoBeamGroupFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMIsoBeamGroup object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMIsoBeamGroup object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMIsoBeamGroupFields(FEMIsoBeamGroupFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMIsoBeamGroup object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMIsoBeamGroupFieldsList(FEMIsoBeamGroupFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMShellDOF object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMShellDOF(FEMShellDOFFields fields) throws ServerError;

    /**
     * Adds a set of FEMShellDOF objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMShellDOFList(FEMShellDOFFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMShellDOF object.
     *
     * @param id  FEMShellDOF object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMShellDOF(long id) throws ServerError;

    /**
     * Gets the FEMShellDOF object proxy.
     *
     * @param id  FEMShellDOF object ID
     * @return FEMShellDOF object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMShellDOF* getFEMShellDOF(long id) throws ServerError;

    /**
     * Gets a list of all FEMShellDOF object IDs.
     *
     * @return list of FEMShellDOF object IDs
     */
    idempotent IdList getFEMShellDOFIds() throws ServerError;

    /**
     * Gets a list of FEMShellDOF object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMShellDOF object IDs
     * @return list of FEMShellDOF object proxies
     */
    idempotent FEMShellDOFList getFEMShellDOFList(IdList ids) throws ServerError;

    /**
     * Gets the FEMShellDOF object fields.
     *
     * @param id FEMShellDOF object ID
     * @return FEMShellDOF object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMShellDOFFields getFEMShellDOFFields(long id) throws ServerError;

    /**
     * Gets a list of FEMShellDOF object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMShellDOF object IDs
     * @return list of FEMShellDOF object fields
     */
    idempotent FEMShellDOFFieldsList getFEMShellDOFFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMShellDOF objects matching the given
     * reference fields.
     *
     * @param fields FEMShellDOF object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMShellDOF objects
     */
    idempotent IdList findEqualFEMShellDOF(FEMShellDOFFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMShellDOF object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMShellDOF object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMShellDOFFields(FEMShellDOFFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMShellDOF object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMShellDOFFieldsList(FEMShellDOFFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMCrossSection object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMCrossSection(FEMCrossSectionFields fields) throws ServerError;

    /**
     * Adds a set of FEMCrossSection objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMCrossSectionList(FEMCrossSectionFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMCrossSection object.
     *
     * @param id  FEMCrossSection object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMCrossSection(long id) throws ServerError;

    /**
     * Gets the FEMCrossSection object proxy.
     *
     * @param id  FEMCrossSection object ID
     * @return FEMCrossSection object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMCrossSection* getFEMCrossSection(long id) throws ServerError;

    /**
     * Gets a list of all FEMCrossSection object IDs.
     *
     * @return list of FEMCrossSection object IDs
     */
    idempotent IdList getFEMCrossSectionIds() throws ServerError;

    /**
     * Gets a list of FEMCrossSection object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMCrossSection object IDs
     * @return list of FEMCrossSection object proxies
     */
    idempotent FEMCrossSectionList getFEMCrossSectionList(IdList ids) throws ServerError;

    /**
     * Gets the FEMCrossSection object fields.
     *
     * @param id FEMCrossSection object ID
     * @return FEMCrossSection object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMCrossSectionFields getFEMCrossSectionFields(long id) throws ServerError;

    /**
     * Gets a list of FEMCrossSection object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMCrossSection object IDs
     * @return list of FEMCrossSection object fields
     */
    idempotent FEMCrossSectionFieldsList getFEMCrossSectionFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMCrossSection objects matching the given
     * reference fields.
     *
     * @param fields FEMCrossSection object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMCrossSection objects
     */
    idempotent IdList findEqualFEMCrossSection(FEMCrossSectionFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMCrossSection object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMCrossSection object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMCrossSectionFields(FEMCrossSectionFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMCrossSection object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMCrossSectionFieldsList(FEMCrossSectionFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMTwistMomentData object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMTwistMomentData(FEMTwistMomentDataFields fields) throws ServerError;

    /**
     * Adds a set of FEMTwistMomentData objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMTwistMomentDataList(FEMTwistMomentDataFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMTwistMomentData object.
     *
     * @param id  FEMTwistMomentData object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMTwistMomentData(long id) throws ServerError;

    /**
     * Gets the FEMTwistMomentData object proxy.
     *
     * @param id  FEMTwistMomentData object ID
     * @return FEMTwistMomentData object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMTwistMomentData* getFEMTwistMomentData(long id) throws ServerError;

    /**
     * Gets a list of all FEMTwistMomentData object IDs.
     *
     * @return list of FEMTwistMomentData object IDs
     */
    idempotent IdList getFEMTwistMomentDataIds() throws ServerError;

    /**
     * Gets a list of FEMTwistMomentData object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMTwistMomentData object IDs
     * @return list of FEMTwistMomentData object proxies
     */
    idempotent FEMTwistMomentDataList getFEMTwistMomentDataList(IdList ids) throws ServerError;

    /**
     * Gets the FEMTwistMomentData object fields.
     *
     * @param id FEMTwistMomentData object ID
     * @return FEMTwistMomentData object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMTwistMomentDataFields getFEMTwistMomentDataFields(long id) throws ServerError;

    /**
     * Gets a list of FEMTwistMomentData object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMTwistMomentData object IDs
     * @return list of FEMTwistMomentData object fields
     */
    idempotent FEMTwistMomentDataFieldsList getFEMTwistMomentDataFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMTwistMomentData objects matching the given
     * reference fields.
     *
     * @param fields FEMTwistMomentData object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMTwistMomentData objects
     */
    idempotent IdList findEqualFEMTwistMomentData(FEMTwistMomentDataFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMTwistMomentData object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMTwistMomentData object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMTwistMomentDataFields(FEMTwistMomentDataFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMTwistMomentData object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMTwistMomentDataFieldsList(FEMTwistMomentDataFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMShell object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMShell(FEMShellFields fields) throws ServerError;

    /**
     * Adds a set of FEMShell objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMShellList(FEMShellFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMShell object.
     *
     * @param id  FEMShell object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMShell(long id) throws ServerError;

    /**
     * Gets the FEMShell object proxy.
     *
     * @param id  FEMShell object ID
     * @return FEMShell object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMShell* getFEMShell(long id) throws ServerError;

    /**
     * Gets a list of all FEMShell object IDs.
     *
     * @return list of FEMShell object IDs
     */
    idempotent IdList getFEMShellIds() throws ServerError;

    /**
     * Gets a list of FEMShell object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMShell object IDs
     * @return list of FEMShell object proxies
     */
    idempotent FEMShellList getFEMShellList(IdList ids) throws ServerError;

    /**
     * Gets the FEMShell object fields.
     *
     * @param id FEMShell object ID
     * @return FEMShell object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMShellFields getFEMShellFields(long id) throws ServerError;

    /**
     * Gets a list of FEMShell object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMShell object IDs
     * @return list of FEMShell object fields
     */
    idempotent FEMShellFieldsList getFEMShellFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMShell objects matching the given
     * reference fields.
     *
     * @param fields FEMShell object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMShell objects
     */
    idempotent IdList findEqualFEMShell(FEMShellFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMShell object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMShell object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMShellFields(FEMShellFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMShell object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMShellFieldsList(FEMShellFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMNTNContact object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMNTNContact(FEMNTNContactFields fields) throws ServerError;

    /**
     * Adds a set of FEMNTNContact objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMNTNContactList(FEMNTNContactFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMNTNContact object.
     *
     * @param id  FEMNTNContact object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMNTNContact(long id) throws ServerError;

    /**
     * Gets the FEMNTNContact object proxy.
     *
     * @param id  FEMNTNContact object ID
     * @return FEMNTNContact object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMNTNContact* getFEMNTNContact(long id) throws ServerError;

    /**
     * Gets a list of all FEMNTNContact object IDs.
     *
     * @return list of FEMNTNContact object IDs
     */
    idempotent IdList getFEMNTNContactIds() throws ServerError;

    /**
     * Gets a list of FEMNTNContact object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMNTNContact object IDs
     * @return list of FEMNTNContact object proxies
     */
    idempotent FEMNTNContactList getFEMNTNContactList(IdList ids) throws ServerError;

    /**
     * Gets the FEMNTNContact object fields.
     *
     * @param id FEMNTNContact object ID
     * @return FEMNTNContact object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMNTNContactFields getFEMNTNContactFields(long id) throws ServerError;

    /**
     * Gets a list of FEMNTNContact object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMNTNContact object IDs
     * @return list of FEMNTNContact object fields
     */
    idempotent FEMNTNContactFieldsList getFEMNTNContactFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMNTNContact objects matching the given
     * reference fields.
     *
     * @param fields FEMNTNContact object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMNTNContact objects
     */
    idempotent IdList findEqualFEMNTNContact(FEMNTNContactFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMNTNContact object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMNTNContact object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMNTNContactFields(FEMNTNContactFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMNTNContact object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMNTNContactFieldsList(FEMNTNContactFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMShellLayer object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMShellLayer(FEMShellLayerFields fields) throws ServerError;

    /**
     * Adds a set of FEMShellLayer objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMShellLayerList(FEMShellLayerFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMShellLayer object.
     *
     * @param id  FEMShellLayer object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMShellLayer(long id) throws ServerError;

    /**
     * Gets the FEMShellLayer object proxy.
     *
     * @param id  FEMShellLayer object ID
     * @return FEMShellLayer object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMShellLayer* getFEMShellLayer(long id) throws ServerError;

    /**
     * Gets a list of all FEMShellLayer object IDs.
     *
     * @return list of FEMShellLayer object IDs
     */
    idempotent IdList getFEMShellLayerIds() throws ServerError;

    /**
     * Gets a list of FEMShellLayer object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMShellLayer object IDs
     * @return list of FEMShellLayer object proxies
     */
    idempotent FEMShellLayerList getFEMShellLayerList(IdList ids) throws ServerError;

    /**
     * Gets the FEMShellLayer object fields.
     *
     * @param id FEMShellLayer object ID
     * @return FEMShellLayer object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMShellLayerFields getFEMShellLayerFields(long id) throws ServerError;

    /**
     * Gets a list of FEMShellLayer object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMShellLayer object IDs
     * @return list of FEMShellLayer object fields
     */
    idempotent FEMShellLayerFieldsList getFEMShellLayerFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMShellLayer objects matching the given
     * reference fields.
     *
     * @param fields FEMShellLayer object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMShellLayer objects
     */
    idempotent IdList findEqualFEMShellLayer(FEMShellLayerFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMShellLayer object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMShellLayer object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMShellLayerFields(FEMShellLayerFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMShellLayer object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMShellLayerFieldsList(FEMShellLayerFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMSkewSysAngles object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMSkewSysAngles(FEMSkewSysAnglesFields fields) throws ServerError;

    /**
     * Adds a set of FEMSkewSysAngles objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMSkewSysAnglesList(FEMSkewSysAnglesFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMSkewSysAngles object.
     *
     * @param id  FEMSkewSysAngles object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMSkewSysAngles(long id) throws ServerError;

    /**
     * Gets the FEMSkewSysAngles object proxy.
     *
     * @param id  FEMSkewSysAngles object ID
     * @return FEMSkewSysAngles object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMSkewSysAngles* getFEMSkewSysAngles(long id) throws ServerError;

    /**
     * Gets a list of all FEMSkewSysAngles object IDs.
     *
     * @return list of FEMSkewSysAngles object IDs
     */
    idempotent IdList getFEMSkewSysAnglesIds() throws ServerError;

    /**
     * Gets a list of FEMSkewSysAngles object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMSkewSysAngles object IDs
     * @return list of FEMSkewSysAngles object proxies
     */
    idempotent FEMSkewSysAnglesList getFEMSkewSysAnglesList(IdList ids) throws ServerError;

    /**
     * Gets the FEMSkewSysAngles object fields.
     *
     * @param id FEMSkewSysAngles object ID
     * @return FEMSkewSysAngles object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMSkewSysAnglesFields getFEMSkewSysAnglesFields(long id) throws ServerError;

    /**
     * Gets a list of FEMSkewSysAngles object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMSkewSysAngles object IDs
     * @return list of FEMSkewSysAngles object fields
     */
    idempotent FEMSkewSysAnglesFieldsList getFEMSkewSysAnglesFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMSkewSysAngles objects matching the given
     * reference fields.
     *
     * @param fields FEMSkewSysAngles object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMSkewSysAngles objects
     */
    idempotent IdList findEqualFEMSkewSysAngles(FEMSkewSysAnglesFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMSkewSysAngles object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMSkewSysAngles object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMSkewSysAnglesFields(FEMSkewSysAnglesFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMSkewSysAngles object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMSkewSysAnglesFieldsList(FEMSkewSysAnglesFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMGroundMotionRecord object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMGroundMotionRecord(FEMGroundMotionRecordFields fields) throws ServerError;

    /**
     * Adds a set of FEMGroundMotionRecord objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMGroundMotionRecordList(FEMGroundMotionRecordFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMGroundMotionRecord object.
     *
     * @param id  FEMGroundMotionRecord object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMGroundMotionRecord(long id) throws ServerError;

    /**
     * Gets the FEMGroundMotionRecord object proxy.
     *
     * @param id  FEMGroundMotionRecord object ID
     * @return FEMGroundMotionRecord object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMGroundMotionRecord* getFEMGroundMotionRecord(long id) throws ServerError;

    /**
     * Gets a list of all FEMGroundMotionRecord object IDs.
     *
     * @return list of FEMGroundMotionRecord object IDs
     */
    idempotent IdList getFEMGroundMotionRecordIds() throws ServerError;

    /**
     * Gets a list of FEMGroundMotionRecord object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMGroundMotionRecord object IDs
     * @return list of FEMGroundMotionRecord object proxies
     */
    idempotent FEMGroundMotionRecordList getFEMGroundMotionRecordList(IdList ids) throws ServerError;

    /**
     * Gets the FEMGroundMotionRecord object fields.
     *
     * @param id FEMGroundMotionRecord object ID
     * @return FEMGroundMotionRecord object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMGroundMotionRecordFields getFEMGroundMotionRecordFields(long id) throws ServerError;

    /**
     * Gets a list of FEMGroundMotionRecord object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMGroundMotionRecord object IDs
     * @return list of FEMGroundMotionRecord object fields
     */
    idempotent FEMGroundMotionRecordFieldsList getFEMGroundMotionRecordFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMGroundMotionRecord objects matching the given
     * reference fields.
     *
     * @param fields FEMGroundMotionRecord object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMGroundMotionRecord objects
     */
    idempotent IdList findEqualFEMGroundMotionRecord(FEMGroundMotionRecordFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMGroundMotionRecord object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMGroundMotionRecord object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMGroundMotionRecordFields(FEMGroundMotionRecordFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMGroundMotionRecord object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMGroundMotionRecordFieldsList(FEMGroundMotionRecordFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMGeneralGroup object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMGeneralGroup(FEMGeneralGroupFields fields) throws ServerError;

    /**
     * Adds a set of FEMGeneralGroup objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMGeneralGroupList(FEMGeneralGroupFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMGeneralGroup object.
     *
     * @param id  FEMGeneralGroup object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMGeneralGroup(long id) throws ServerError;

    /**
     * Gets the FEMGeneralGroup object proxy.
     *
     * @param id  FEMGeneralGroup object ID
     * @return FEMGeneralGroup object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMGeneralGroup* getFEMGeneralGroup(long id) throws ServerError;

    /**
     * Gets a list of all FEMGeneralGroup object IDs.
     *
     * @return list of FEMGeneralGroup object IDs
     */
    idempotent IdList getFEMGeneralGroupIds() throws ServerError;

    /**
     * Gets a list of FEMGeneralGroup object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMGeneralGroup object IDs
     * @return list of FEMGeneralGroup object proxies
     */
    idempotent FEMGeneralGroupList getFEMGeneralGroupList(IdList ids) throws ServerError;

    /**
     * Gets the FEMGeneralGroup object fields.
     *
     * @param id FEMGeneralGroup object ID
     * @return FEMGeneralGroup object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMGeneralGroupFields getFEMGeneralGroupFields(long id) throws ServerError;

    /**
     * Gets a list of FEMGeneralGroup object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMGeneralGroup object IDs
     * @return list of FEMGeneralGroup object fields
     */
    idempotent FEMGeneralGroupFieldsList getFEMGeneralGroupFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMGeneralGroup objects matching the given
     * reference fields.
     *
     * @param fields FEMGeneralGroup object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMGeneralGroup objects
     */
    idempotent IdList findEqualFEMGeneralGroup(FEMGeneralGroupFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMGeneralGroup object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMGeneralGroup object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMGeneralGroupFields(FEMGeneralGroupFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMGeneralGroup object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMGeneralGroupFieldsList(FEMGeneralGroupFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMTwoDSolid object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMTwoDSolid(FEMTwoDSolidFields fields) throws ServerError;

    /**
     * Adds a set of FEMTwoDSolid objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMTwoDSolidList(FEMTwoDSolidFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMTwoDSolid object.
     *
     * @param id  FEMTwoDSolid object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMTwoDSolid(long id) throws ServerError;

    /**
     * Gets the FEMTwoDSolid object proxy.
     *
     * @param id  FEMTwoDSolid object ID
     * @return FEMTwoDSolid object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMTwoDSolid* getFEMTwoDSolid(long id) throws ServerError;

    /**
     * Gets a list of all FEMTwoDSolid object IDs.
     *
     * @return list of FEMTwoDSolid object IDs
     */
    idempotent IdList getFEMTwoDSolidIds() throws ServerError;

    /**
     * Gets a list of FEMTwoDSolid object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMTwoDSolid object IDs
     * @return list of FEMTwoDSolid object proxies
     */
    idempotent FEMTwoDSolidList getFEMTwoDSolidList(IdList ids) throws ServerError;

    /**
     * Gets the FEMTwoDSolid object fields.
     *
     * @param id FEMTwoDSolid object ID
     * @return FEMTwoDSolid object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMTwoDSolidFields getFEMTwoDSolidFields(long id) throws ServerError;

    /**
     * Gets a list of FEMTwoDSolid object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMTwoDSolid object IDs
     * @return list of FEMTwoDSolid object fields
     */
    idempotent FEMTwoDSolidFieldsList getFEMTwoDSolidFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMTwoDSolid objects matching the given
     * reference fields.
     *
     * @param fields FEMTwoDSolid object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMTwoDSolid objects
     */
    idempotent IdList findEqualFEMTwoDSolid(FEMTwoDSolidFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMTwoDSolid object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMTwoDSolid object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMTwoDSolidFields(FEMTwoDSolidFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMTwoDSolid object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMTwoDSolidFieldsList(FEMTwoDSolidFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMAppliedTemperature object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMAppliedTemperature(FEMAppliedTemperatureFields fields) throws ServerError;

    /**
     * Adds a set of FEMAppliedTemperature objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMAppliedTemperatureList(FEMAppliedTemperatureFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMAppliedTemperature object.
     *
     * @param id  FEMAppliedTemperature object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMAppliedTemperature(long id) throws ServerError;

    /**
     * Gets the FEMAppliedTemperature object proxy.
     *
     * @param id  FEMAppliedTemperature object ID
     * @return FEMAppliedTemperature object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMAppliedTemperature* getFEMAppliedTemperature(long id) throws ServerError;

    /**
     * Gets a list of all FEMAppliedTemperature object IDs.
     *
     * @return list of FEMAppliedTemperature object IDs
     */
    idempotent IdList getFEMAppliedTemperatureIds() throws ServerError;

    /**
     * Gets a list of FEMAppliedTemperature object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMAppliedTemperature object IDs
     * @return list of FEMAppliedTemperature object proxies
     */
    idempotent FEMAppliedTemperatureList getFEMAppliedTemperatureList(IdList ids) throws ServerError;

    /**
     * Gets the FEMAppliedTemperature object fields.
     *
     * @param id FEMAppliedTemperature object ID
     * @return FEMAppliedTemperature object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMAppliedTemperatureFields getFEMAppliedTemperatureFields(long id) throws ServerError;

    /**
     * Gets a list of FEMAppliedTemperature object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMAppliedTemperature object IDs
     * @return list of FEMAppliedTemperature object fields
     */
    idempotent FEMAppliedTemperatureFieldsList getFEMAppliedTemperatureFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMAppliedTemperature objects matching the given
     * reference fields.
     *
     * @param fields FEMAppliedTemperature object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMAppliedTemperature objects
     */
    idempotent IdList findEqualFEMAppliedTemperature(FEMAppliedTemperatureFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMAppliedTemperature object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMAppliedTemperature object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMAppliedTemperatureFields(FEMAppliedTemperatureFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMAppliedTemperature object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMAppliedTemperatureFieldsList(FEMAppliedTemperatureFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMMatrixSets object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMMatrixSets(FEMMatrixSetsFields fields) throws ServerError;

    /**
     * Adds a set of FEMMatrixSets objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMMatrixSetsList(FEMMatrixSetsFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMMatrixSets object.
     *
     * @param id  FEMMatrixSets object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMMatrixSets(long id) throws ServerError;

    /**
     * Gets the FEMMatrixSets object proxy.
     *
     * @param id  FEMMatrixSets object ID
     * @return FEMMatrixSets object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMMatrixSets* getFEMMatrixSets(long id) throws ServerError;

    /**
     * Gets a list of all FEMMatrixSets object IDs.
     *
     * @return list of FEMMatrixSets object IDs
     */
    idempotent IdList getFEMMatrixSetsIds() throws ServerError;

    /**
     * Gets a list of FEMMatrixSets object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMMatrixSets object IDs
     * @return list of FEMMatrixSets object proxies
     */
    idempotent FEMMatrixSetsList getFEMMatrixSetsList(IdList ids) throws ServerError;

    /**
     * Gets the FEMMatrixSets object fields.
     *
     * @param id FEMMatrixSets object ID
     * @return FEMMatrixSets object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMMatrixSetsFields getFEMMatrixSetsFields(long id) throws ServerError;

    /**
     * Gets a list of FEMMatrixSets object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMMatrixSets object IDs
     * @return list of FEMMatrixSets object fields
     */
    idempotent FEMMatrixSetsFieldsList getFEMMatrixSetsFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMMatrixSets objects matching the given
     * reference fields.
     *
     * @param fields FEMMatrixSets object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMMatrixSets objects
     */
    idempotent IdList findEqualFEMMatrixSets(FEMMatrixSetsFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMMatrixSets object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMMatrixSets object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMMatrixSetsFields(FEMMatrixSetsFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMMatrixSets object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMMatrixSetsFieldsList(FEMMatrixSetsFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMConstraintCoef object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMConstraintCoef(FEMConstraintCoefFields fields) throws ServerError;

    /**
     * Adds a set of FEMConstraintCoef objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMConstraintCoefList(FEMConstraintCoefFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMConstraintCoef object.
     *
     * @param id  FEMConstraintCoef object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMConstraintCoef(long id) throws ServerError;

    /**
     * Gets the FEMConstraintCoef object proxy.
     *
     * @param id  FEMConstraintCoef object ID
     * @return FEMConstraintCoef object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMConstraintCoef* getFEMConstraintCoef(long id) throws ServerError;

    /**
     * Gets a list of all FEMConstraintCoef object IDs.
     *
     * @return list of FEMConstraintCoef object IDs
     */
    idempotent IdList getFEMConstraintCoefIds() throws ServerError;

    /**
     * Gets a list of FEMConstraintCoef object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMConstraintCoef object IDs
     * @return list of FEMConstraintCoef object proxies
     */
    idempotent FEMConstraintCoefList getFEMConstraintCoefList(IdList ids) throws ServerError;

    /**
     * Gets the FEMConstraintCoef object fields.
     *
     * @param id FEMConstraintCoef object ID
     * @return FEMConstraintCoef object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMConstraintCoefFields getFEMConstraintCoefFields(long id) throws ServerError;

    /**
     * Gets a list of FEMConstraintCoef object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMConstraintCoef object IDs
     * @return list of FEMConstraintCoef object fields
     */
    idempotent FEMConstraintCoefFieldsList getFEMConstraintCoefFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMConstraintCoef objects matching the given
     * reference fields.
     *
     * @param fields FEMConstraintCoef object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMConstraintCoef objects
     */
    idempotent IdList findEqualFEMConstraintCoef(FEMConstraintCoefFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMConstraintCoef object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMConstraintCoef object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMConstraintCoefFields(FEMConstraintCoefFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMConstraintCoef object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMConstraintCoefFieldsList(FEMConstraintCoefFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMSectionBox object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMSectionBox(FEMSectionBoxFields fields) throws ServerError;

    /**
     * Adds a set of FEMSectionBox objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMSectionBoxList(FEMSectionBoxFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMSectionBox object.
     *
     * @param id  FEMSectionBox object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMSectionBox(long id) throws ServerError;

    /**
     * Gets the FEMSectionBox object proxy.
     *
     * @param id  FEMSectionBox object ID
     * @return FEMSectionBox object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMSectionBox* getFEMSectionBox(long id) throws ServerError;

    /**
     * Gets a list of all FEMSectionBox object IDs.
     *
     * @return list of FEMSectionBox object IDs
     */
    idempotent IdList getFEMSectionBoxIds() throws ServerError;

    /**
     * Gets a list of FEMSectionBox object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMSectionBox object IDs
     * @return list of FEMSectionBox object proxies
     */
    idempotent FEMSectionBoxList getFEMSectionBoxList(IdList ids) throws ServerError;

    /**
     * Gets the FEMSectionBox object fields.
     *
     * @param id FEMSectionBox object ID
     * @return FEMSectionBox object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMSectionBoxFields getFEMSectionBoxFields(long id) throws ServerError;

    /**
     * Gets a list of FEMSectionBox object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMSectionBox object IDs
     * @return list of FEMSectionBox object fields
     */
    idempotent FEMSectionBoxFieldsList getFEMSectionBoxFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMSectionBox objects matching the given
     * reference fields.
     *
     * @param fields FEMSectionBox object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMSectionBox objects
     */
    idempotent IdList findEqualFEMSectionBox(FEMSectionBoxFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMSectionBox object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMSectionBox object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMSectionBoxFields(FEMSectionBoxFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMSectionBox object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMSectionBoxFieldsList(FEMSectionBoxFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMNKDisplForce object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMNKDisplForce(FEMNKDisplForceFields fields) throws ServerError;

    /**
     * Adds a set of FEMNKDisplForce objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMNKDisplForceList(FEMNKDisplForceFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMNKDisplForce object.
     *
     * @param id  FEMNKDisplForce object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMNKDisplForce(long id) throws ServerError;

    /**
     * Gets the FEMNKDisplForce object proxy.
     *
     * @param id  FEMNKDisplForce object ID
     * @return FEMNKDisplForce object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMNKDisplForce* getFEMNKDisplForce(long id) throws ServerError;

    /**
     * Gets a list of all FEMNKDisplForce object IDs.
     *
     * @return list of FEMNKDisplForce object IDs
     */
    idempotent IdList getFEMNKDisplForceIds() throws ServerError;

    /**
     * Gets a list of FEMNKDisplForce object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMNKDisplForce object IDs
     * @return list of FEMNKDisplForce object proxies
     */
    idempotent FEMNKDisplForceList getFEMNKDisplForceList(IdList ids) throws ServerError;

    /**
     * Gets the FEMNKDisplForce object fields.
     *
     * @param id FEMNKDisplForce object ID
     * @return FEMNKDisplForce object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMNKDisplForceFields getFEMNKDisplForceFields(long id) throws ServerError;

    /**
     * Gets a list of FEMNKDisplForce object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMNKDisplForce object IDs
     * @return list of FEMNKDisplForce object fields
     */
    idempotent FEMNKDisplForceFieldsList getFEMNKDisplForceFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMNKDisplForce objects matching the given
     * reference fields.
     *
     * @param fields FEMNKDisplForce object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMNKDisplForce objects
     */
    idempotent IdList findEqualFEMNKDisplForce(FEMNKDisplForceFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMNKDisplForce object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMNKDisplForce object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMNKDisplForceFields(FEMNKDisplForceFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMNKDisplForce object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMNKDisplForceFieldsList(FEMNKDisplForceFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMPlasticStrainStress object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMPlasticStrainStress(FEMPlasticStrainStressFields fields) throws ServerError;

    /**
     * Adds a set of FEMPlasticStrainStress objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMPlasticStrainStressList(FEMPlasticStrainStressFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMPlasticStrainStress object.
     *
     * @param id  FEMPlasticStrainStress object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMPlasticStrainStress(long id) throws ServerError;

    /**
     * Gets the FEMPlasticStrainStress object proxy.
     *
     * @param id  FEMPlasticStrainStress object ID
     * @return FEMPlasticStrainStress object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMPlasticStrainStress* getFEMPlasticStrainStress(long id) throws ServerError;

    /**
     * Gets a list of all FEMPlasticStrainStress object IDs.
     *
     * @return list of FEMPlasticStrainStress object IDs
     */
    idempotent IdList getFEMPlasticStrainStressIds() throws ServerError;

    /**
     * Gets a list of FEMPlasticStrainStress object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMPlasticStrainStress object IDs
     * @return list of FEMPlasticStrainStress object proxies
     */
    idempotent FEMPlasticStrainStressList getFEMPlasticStrainStressList(IdList ids) throws ServerError;

    /**
     * Gets the FEMPlasticStrainStress object fields.
     *
     * @param id FEMPlasticStrainStress object ID
     * @return FEMPlasticStrainStress object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMPlasticStrainStressFields getFEMPlasticStrainStressFields(long id) throws ServerError;

    /**
     * Gets a list of FEMPlasticStrainStress object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMPlasticStrainStress object IDs
     * @return list of FEMPlasticStrainStress object fields
     */
    idempotent FEMPlasticStrainStressFieldsList getFEMPlasticStrainStressFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMPlasticStrainStress objects matching the given
     * reference fields.
     *
     * @param fields FEMPlasticStrainStress object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMPlasticStrainStress objects
     */
    idempotent IdList findEqualFEMPlasticStrainStress(FEMPlasticStrainStressFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMPlasticStrainStress object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMPlasticStrainStress object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMPlasticStrainStressFields(FEMPlasticStrainStressFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMPlasticStrainStress object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMPlasticStrainStressFieldsList(FEMPlasticStrainStressFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMShellAxesOrthoData object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMShellAxesOrthoData(FEMShellAxesOrthoDataFields fields) throws ServerError;

    /**
     * Adds a set of FEMShellAxesOrthoData objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMShellAxesOrthoDataList(FEMShellAxesOrthoDataFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMShellAxesOrthoData object.
     *
     * @param id  FEMShellAxesOrthoData object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMShellAxesOrthoData(long id) throws ServerError;

    /**
     * Gets the FEMShellAxesOrthoData object proxy.
     *
     * @param id  FEMShellAxesOrthoData object ID
     * @return FEMShellAxesOrthoData object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMShellAxesOrthoData* getFEMShellAxesOrthoData(long id) throws ServerError;

    /**
     * Gets a list of all FEMShellAxesOrthoData object IDs.
     *
     * @return list of FEMShellAxesOrthoData object IDs
     */
    idempotent IdList getFEMShellAxesOrthoDataIds() throws ServerError;

    /**
     * Gets a list of FEMShellAxesOrthoData object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMShellAxesOrthoData object IDs
     * @return list of FEMShellAxesOrthoData object proxies
     */
    idempotent FEMShellAxesOrthoDataList getFEMShellAxesOrthoDataList(IdList ids) throws ServerError;

    /**
     * Gets the FEMShellAxesOrthoData object fields.
     *
     * @param id FEMShellAxesOrthoData object ID
     * @return FEMShellAxesOrthoData object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMShellAxesOrthoDataFields getFEMShellAxesOrthoDataFields(long id) throws ServerError;

    /**
     * Gets a list of FEMShellAxesOrthoData object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMShellAxesOrthoData object IDs
     * @return list of FEMShellAxesOrthoData object fields
     */
    idempotent FEMShellAxesOrthoDataFieldsList getFEMShellAxesOrthoDataFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMShellAxesOrthoData objects matching the given
     * reference fields.
     *
     * @param fields FEMShellAxesOrthoData object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMShellAxesOrthoData objects
     */
    idempotent IdList findEqualFEMShellAxesOrthoData(FEMShellAxesOrthoDataFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMShellAxesOrthoData object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMShellAxesOrthoData object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMShellAxesOrthoDataFields(FEMShellAxesOrthoDataFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMShellAxesOrthoData object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMShellAxesOrthoDataFieldsList(FEMShellAxesOrthoDataFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMGeneralNode object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMGeneralNode(FEMGeneralNodeFields fields) throws ServerError;

    /**
     * Adds a set of FEMGeneralNode objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMGeneralNodeList(FEMGeneralNodeFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMGeneralNode object.
     *
     * @param id  FEMGeneralNode object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMGeneralNode(long id) throws ServerError;

    /**
     * Gets the FEMGeneralNode object proxy.
     *
     * @param id  FEMGeneralNode object ID
     * @return FEMGeneralNode object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMGeneralNode* getFEMGeneralNode(long id) throws ServerError;

    /**
     * Gets a list of all FEMGeneralNode object IDs.
     *
     * @return list of FEMGeneralNode object IDs
     */
    idempotent IdList getFEMGeneralNodeIds() throws ServerError;

    /**
     * Gets a list of FEMGeneralNode object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMGeneralNode object IDs
     * @return list of FEMGeneralNode object proxies
     */
    idempotent FEMGeneralNodeList getFEMGeneralNodeList(IdList ids) throws ServerError;

    /**
     * Gets the FEMGeneralNode object fields.
     *
     * @param id FEMGeneralNode object ID
     * @return FEMGeneralNode object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMGeneralNodeFields getFEMGeneralNodeFields(long id) throws ServerError;

    /**
     * Gets a list of FEMGeneralNode object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMGeneralNode object IDs
     * @return list of FEMGeneralNode object fields
     */
    idempotent FEMGeneralNodeFieldsList getFEMGeneralNodeFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMGeneralNode objects matching the given
     * reference fields.
     *
     * @param fields FEMGeneralNode object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMGeneralNode objects
     */
    idempotent IdList findEqualFEMGeneralNode(FEMGeneralNodeFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMGeneralNode object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMGeneralNode object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMGeneralNodeFields(FEMGeneralNodeFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMGeneralNode object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMGeneralNodeFieldsList(FEMGeneralNodeFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMStrLines object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMStrLines(FEMStrLinesFields fields) throws ServerError;

    /**
     * Adds a set of FEMStrLines objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMStrLinesList(FEMStrLinesFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMStrLines object.
     *
     * @param id  FEMStrLines object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMStrLines(long id) throws ServerError;

    /**
     * Gets the FEMStrLines object proxy.
     *
     * @param id  FEMStrLines object ID
     * @return FEMStrLines object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMStrLines* getFEMStrLines(long id) throws ServerError;

    /**
     * Gets a list of all FEMStrLines object IDs.
     *
     * @return list of FEMStrLines object IDs
     */
    idempotent IdList getFEMStrLinesIds() throws ServerError;

    /**
     * Gets a list of FEMStrLines object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMStrLines object IDs
     * @return list of FEMStrLines object proxies
     */
    idempotent FEMStrLinesList getFEMStrLinesList(IdList ids) throws ServerError;

    /**
     * Gets the FEMStrLines object fields.
     *
     * @param id FEMStrLines object ID
     * @return FEMStrLines object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMStrLinesFields getFEMStrLinesFields(long id) throws ServerError;

    /**
     * Gets a list of FEMStrLines object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMStrLines object IDs
     * @return list of FEMStrLines object fields
     */
    idempotent FEMStrLinesFieldsList getFEMStrLinesFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMStrLines objects matching the given
     * reference fields.
     *
     * @param fields FEMStrLines object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMStrLines objects
     */
    idempotent IdList findEqualFEMStrLines(FEMStrLinesFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMStrLines object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMStrLines object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMStrLinesFields(FEMStrLinesFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMStrLines object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMStrLinesFieldsList(FEMStrLinesFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMContactSurface object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMContactSurface(FEMContactSurfaceFields fields) throws ServerError;

    /**
     * Adds a set of FEMContactSurface objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMContactSurfaceList(FEMContactSurfaceFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMContactSurface object.
     *
     * @param id  FEMContactSurface object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMContactSurface(long id) throws ServerError;

    /**
     * Gets the FEMContactSurface object proxy.
     *
     * @param id  FEMContactSurface object ID
     * @return FEMContactSurface object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMContactSurface* getFEMContactSurface(long id) throws ServerError;

    /**
     * Gets a list of all FEMContactSurface object IDs.
     *
     * @return list of FEMContactSurface object IDs
     */
    idempotent IdList getFEMContactSurfaceIds() throws ServerError;

    /**
     * Gets a list of FEMContactSurface object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMContactSurface object IDs
     * @return list of FEMContactSurface object proxies
     */
    idempotent FEMContactSurfaceList getFEMContactSurfaceList(IdList ids) throws ServerError;

    /**
     * Gets the FEMContactSurface object fields.
     *
     * @param id FEMContactSurface object ID
     * @return FEMContactSurface object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMContactSurfaceFields getFEMContactSurfaceFields(long id) throws ServerError;

    /**
     * Gets a list of FEMContactSurface object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMContactSurface object IDs
     * @return list of FEMContactSurface object fields
     */
    idempotent FEMContactSurfaceFieldsList getFEMContactSurfaceFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMContactSurface objects matching the given
     * reference fields.
     *
     * @param fields FEMContactSurface object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMContactSurface objects
     */
    idempotent IdList findEqualFEMContactSurface(FEMContactSurfaceFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMContactSurface object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMContactSurface object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMContactSurfaceFields(FEMContactSurfaceFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMContactSurface object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMContactSurfaceFieldsList(FEMContactSurfaceFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMMCForceData object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMMCForceData(FEMMCForceDataFields fields) throws ServerError;

    /**
     * Adds a set of FEMMCForceData objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMMCForceDataList(FEMMCForceDataFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMMCForceData object.
     *
     * @param id  FEMMCForceData object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMMCForceData(long id) throws ServerError;

    /**
     * Gets the FEMMCForceData object proxy.
     *
     * @param id  FEMMCForceData object ID
     * @return FEMMCForceData object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMMCForceData* getFEMMCForceData(long id) throws ServerError;

    /**
     * Gets a list of all FEMMCForceData object IDs.
     *
     * @return list of FEMMCForceData object IDs
     */
    idempotent IdList getFEMMCForceDataIds() throws ServerError;

    /**
     * Gets a list of FEMMCForceData object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMMCForceData object IDs
     * @return list of FEMMCForceData object proxies
     */
    idempotent FEMMCForceDataList getFEMMCForceDataList(IdList ids) throws ServerError;

    /**
     * Gets the FEMMCForceData object fields.
     *
     * @param id FEMMCForceData object ID
     * @return FEMMCForceData object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMMCForceDataFields getFEMMCForceDataFields(long id) throws ServerError;

    /**
     * Gets a list of FEMMCForceData object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMMCForceData object IDs
     * @return list of FEMMCForceData object fields
     */
    idempotent FEMMCForceDataFieldsList getFEMMCForceDataFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMMCForceData objects matching the given
     * reference fields.
     *
     * @param fields FEMMCForceData object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMMCForceData objects
     */
    idempotent IdList findEqualFEMMCForceData(FEMMCForceDataFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMMCForceData object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMMCForceData object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMMCForceDataFields(FEMMCForceDataFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMMCForceData object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMMCForceDataFieldsList(FEMMCForceDataFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMSpring object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMSpring(FEMSpringFields fields) throws ServerError;

    /**
     * Adds a set of FEMSpring objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMSpringList(FEMSpringFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMSpring object.
     *
     * @param id  FEMSpring object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMSpring(long id) throws ServerError;

    /**
     * Gets the FEMSpring object proxy.
     *
     * @param id  FEMSpring object ID
     * @return FEMSpring object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMSpring* getFEMSpring(long id) throws ServerError;

    /**
     * Gets a list of all FEMSpring object IDs.
     *
     * @return list of FEMSpring object IDs
     */
    idempotent IdList getFEMSpringIds() throws ServerError;

    /**
     * Gets a list of FEMSpring object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMSpring object IDs
     * @return list of FEMSpring object proxies
     */
    idempotent FEMSpringList getFEMSpringList(IdList ids) throws ServerError;

    /**
     * Gets the FEMSpring object fields.
     *
     * @param id FEMSpring object ID
     * @return FEMSpring object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMSpringFields getFEMSpringFields(long id) throws ServerError;

    /**
     * Gets a list of FEMSpring object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMSpring object IDs
     * @return list of FEMSpring object fields
     */
    idempotent FEMSpringFieldsList getFEMSpringFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMSpring objects matching the given
     * reference fields.
     *
     * @param fields FEMSpring object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMSpring objects
     */
    idempotent IdList findEqualFEMSpring(FEMSpringFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMSpring object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMSpring object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMSpringFields(FEMSpringFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMSpring object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMSpringFieldsList(FEMSpringFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMSpringGroup object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMSpringGroup(FEMSpringGroupFields fields) throws ServerError;

    /**
     * Adds a set of FEMSpringGroup objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMSpringGroupList(FEMSpringGroupFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMSpringGroup object.
     *
     * @param id  FEMSpringGroup object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMSpringGroup(long id) throws ServerError;

    /**
     * Gets the FEMSpringGroup object proxy.
     *
     * @param id  FEMSpringGroup object ID
     * @return FEMSpringGroup object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMSpringGroup* getFEMSpringGroup(long id) throws ServerError;

    /**
     * Gets a list of all FEMSpringGroup object IDs.
     *
     * @return list of FEMSpringGroup object IDs
     */
    idempotent IdList getFEMSpringGroupIds() throws ServerError;

    /**
     * Gets a list of FEMSpringGroup object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMSpringGroup object IDs
     * @return list of FEMSpringGroup object proxies
     */
    idempotent FEMSpringGroupList getFEMSpringGroupList(IdList ids) throws ServerError;

    /**
     * Gets the FEMSpringGroup object fields.
     *
     * @param id FEMSpringGroup object ID
     * @return FEMSpringGroup object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMSpringGroupFields getFEMSpringGroupFields(long id) throws ServerError;

    /**
     * Gets a list of FEMSpringGroup object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMSpringGroup object IDs
     * @return list of FEMSpringGroup object fields
     */
    idempotent FEMSpringGroupFieldsList getFEMSpringGroupFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMSpringGroup objects matching the given
     * reference fields.
     *
     * @param fields FEMSpringGroup object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMSpringGroup objects
     */
    idempotent IdList findEqualFEMSpringGroup(FEMSpringGroupFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMSpringGroup object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMSpringGroup object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMSpringGroupFields(FEMSpringGroupFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMSpringGroup object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMSpringGroupFieldsList(FEMSpringGroupFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FEMShellGroup object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFEMShellGroup(FEMShellGroupFields fields) throws ServerError;

    /**
     * Adds a set of FEMShellGroup objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFEMShellGroupList(FEMShellGroupFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FEMShellGroup object.
     *
     * @param id  FEMShellGroup object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFEMShellGroup(long id) throws ServerError;

    /**
     * Gets the FEMShellGroup object proxy.
     *
     * @param id  FEMShellGroup object ID
     * @return FEMShellGroup object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMShellGroup* getFEMShellGroup(long id) throws ServerError;

    /**
     * Gets a list of all FEMShellGroup object IDs.
     *
     * @return list of FEMShellGroup object IDs
     */
    idempotent IdList getFEMShellGroupIds() throws ServerError;

    /**
     * Gets a list of FEMShellGroup object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMShellGroup object IDs
     * @return list of FEMShellGroup object proxies
     */
    idempotent FEMShellGroupList getFEMShellGroupList(IdList ids) throws ServerError;

    /**
     * Gets the FEMShellGroup object fields.
     *
     * @param id FEMShellGroup object ID
     * @return FEMShellGroup object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FEMShellGroupFields getFEMShellGroupFields(long id) throws ServerError;

    /**
     * Gets a list of FEMShellGroup object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FEMShellGroup object IDs
     * @return list of FEMShellGroup object fields
     */
    idempotent FEMShellGroupFieldsList getFEMShellGroupFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FEMShellGroup objects matching the given
     * reference fields.
     *
     * @param fields FEMShellGroup object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FEMShellGroup objects
     */
    idempotent IdList findEqualFEMShellGroup(FEMShellGroupFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMShellGroup object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FEMShellGroup object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMShellGroupFields(FEMShellGroupFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FEMShellGroup object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFEMShellGroupFieldsList(FEMShellGroupFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a DaqUnit object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addDaqUnit(DaqUnitFields fields) throws ServerError;

    /**
     * Adds a set of DaqUnit objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addDaqUnitList(DaqUnitFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified DaqUnit object.
     *
     * @param id  DaqUnit object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delDaqUnit(long id) throws ServerError;

    /**
     * Gets the DaqUnit object proxy.
     *
     * @param id  DaqUnit object ID
     * @return DaqUnit object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent DaqUnit* getDaqUnit(long id) throws ServerError;

    /**
     * Gets a list of all DaqUnit object IDs.
     *
     * @return list of DaqUnit object IDs
     */
    idempotent IdList getDaqUnitIds() throws ServerError;

    /**
     * Gets a list of DaqUnit object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of DaqUnit object IDs
     * @return list of DaqUnit object proxies
     */
    idempotent DaqUnitList getDaqUnitList(IdList ids) throws ServerError;

    /**
     * Gets the DaqUnit object fields.
     *
     * @param id DaqUnit object ID
     * @return DaqUnit object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent DaqUnitFields getDaqUnitFields(long id) throws ServerError;

    /**
     * Gets a list of DaqUnit object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of DaqUnit object IDs
     * @return list of DaqUnit object fields
     */
    idempotent DaqUnitFieldsList getDaqUnitFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all DaqUnit objects matching the given
     * reference fields.
     *
     * @param fields DaqUnit object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching DaqUnit objects
     */
    idempotent IdList findEqualDaqUnit(DaqUnitFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named DaqUnit object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields DaqUnit object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setDaqUnitFields(DaqUnitFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named DaqUnit object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setDaqUnitFieldsList(DaqUnitFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a DaqUnitChannel object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addDaqUnitChannel(DaqUnitChannelFields fields) throws ServerError;

    /**
     * Adds a set of DaqUnitChannel objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addDaqUnitChannelList(DaqUnitChannelFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified DaqUnitChannel object.
     *
     * @param id  DaqUnitChannel object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delDaqUnitChannel(long id) throws ServerError;

    /**
     * Gets the DaqUnitChannel object proxy.
     *
     * @param id  DaqUnitChannel object ID
     * @return DaqUnitChannel object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent DaqUnitChannel* getDaqUnitChannel(long id) throws ServerError;

    /**
     * Gets a list of all DaqUnitChannel object IDs.
     *
     * @return list of DaqUnitChannel object IDs
     */
    idempotent IdList getDaqUnitChannelIds() throws ServerError;

    /**
     * Gets a list of DaqUnitChannel object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of DaqUnitChannel object IDs
     * @return list of DaqUnitChannel object proxies
     */
    idempotent DaqUnitChannelList getDaqUnitChannelList(IdList ids) throws ServerError;

    /**
     * Gets the DaqUnitChannel object fields.
     *
     * @param id DaqUnitChannel object ID
     * @return DaqUnitChannel object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent DaqUnitChannelFields getDaqUnitChannelFields(long id) throws ServerError;

    /**
     * Gets a list of DaqUnitChannel object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of DaqUnitChannel object IDs
     * @return list of DaqUnitChannel object fields
     */
    idempotent DaqUnitChannelFieldsList getDaqUnitChannelFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all DaqUnitChannel objects matching the given
     * reference fields.
     *
     * @param fields DaqUnitChannel object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching DaqUnitChannel objects
     */
    idempotent IdList findEqualDaqUnitChannel(DaqUnitChannelFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named DaqUnitChannel object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields DaqUnitChannel object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setDaqUnitChannelFields(DaqUnitChannelFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named DaqUnitChannel object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setDaqUnitChannelFieldsList(DaqUnitChannelFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a Sensor object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addSensor(SensorFields fields) throws ServerError;

    /**
     * Adds a set of Sensor objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addSensorList(SensorFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified Sensor object.
     *
     * @param id  Sensor object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delSensor(long id) throws ServerError;

    /**
     * Gets the Sensor object proxy.
     *
     * @param id  Sensor object ID
     * @return Sensor object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent Sensor* getSensor(long id) throws ServerError;

    /**
     * Gets a list of all Sensor object IDs.
     *
     * @return list of Sensor object IDs
     */
    idempotent IdList getSensorIds() throws ServerError;

    /**
     * Gets a list of Sensor object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of Sensor object IDs
     * @return list of Sensor object proxies
     */
    idempotent SensorList getSensorList(IdList ids) throws ServerError;

    /**
     * Gets the Sensor object fields.
     *
     * @param id Sensor object ID
     * @return Sensor object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent SensorFields getSensorFields(long id) throws ServerError;

    /**
     * Gets a list of Sensor object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of Sensor object IDs
     * @return list of Sensor object fields
     */
    idempotent SensorFieldsList getSensorFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all Sensor objects matching the given
     * reference fields.
     *
     * @param fields Sensor object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching Sensor objects
     */
    idempotent IdList findEqualSensor(SensorFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named Sensor object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields Sensor object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setSensorFields(SensorFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named Sensor object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setSensorFieldsList(SensorFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a SensorChannel object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addSensorChannel(SensorChannelFields fields) throws ServerError;

    /**
     * Adds a set of SensorChannel objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addSensorChannelList(SensorChannelFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified SensorChannel object.
     *
     * @param id  SensorChannel object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delSensorChannel(long id) throws ServerError;

    /**
     * Gets the SensorChannel object proxy.
     *
     * @param id  SensorChannel object ID
     * @return SensorChannel object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent SensorChannel* getSensorChannel(long id) throws ServerError;

    /**
     * Gets a list of all SensorChannel object IDs.
     *
     * @return list of SensorChannel object IDs
     */
    idempotent IdList getSensorChannelIds() throws ServerError;

    /**
     * Gets a list of SensorChannel object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of SensorChannel object IDs
     * @return list of SensorChannel object proxies
     */
    idempotent SensorChannelList getSensorChannelList(IdList ids) throws ServerError;

    /**
     * Gets the SensorChannel object fields.
     *
     * @param id SensorChannel object ID
     * @return SensorChannel object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent SensorChannelFields getSensorChannelFields(long id) throws ServerError;

    /**
     * Gets a list of SensorChannel object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of SensorChannel object IDs
     * @return list of SensorChannel object fields
     */
    idempotent SensorChannelFieldsList getSensorChannelFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all SensorChannel objects matching the given
     * reference fields.
     *
     * @param fields SensorChannel object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching SensorChannel objects
     */
    idempotent IdList findEqualSensorChannel(SensorChannelFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named SensorChannel object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields SensorChannel object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setSensorChannelFields(SensorChannelFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named SensorChannel object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setSensorChannelFieldsList(SensorChannelFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a SensorChannelConnection object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addSensorChannelConnection(SensorChannelConnectionFields fields) throws ServerError;

    /**
     * Adds a set of SensorChannelConnection objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addSensorChannelConnectionList(SensorChannelConnectionFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified SensorChannelConnection object.
     *
     * @param id  SensorChannelConnection object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delSensorChannelConnection(long id) throws ServerError;

    /**
     * Gets the SensorChannelConnection object proxy.
     *
     * @param id  SensorChannelConnection object ID
     * @return SensorChannelConnection object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent SensorChannelConnection* getSensorChannelConnection(long id) throws ServerError;

    /**
     * Gets a list of all SensorChannelConnection object IDs.
     *
     * @return list of SensorChannelConnection object IDs
     */
    idempotent IdList getSensorChannelConnectionIds() throws ServerError;

    /**
     * Gets a list of SensorChannelConnection object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of SensorChannelConnection object IDs
     * @return list of SensorChannelConnection object proxies
     */
    idempotent SensorChannelConnectionList getSensorChannelConnectionList(IdList ids) throws ServerError;

    /**
     * Gets the SensorChannelConnection object fields.
     *
     * @param id SensorChannelConnection object ID
     * @return SensorChannelConnection object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent SensorChannelConnectionFields getSensorChannelConnectionFields(long id) throws ServerError;

    /**
     * Gets a list of SensorChannelConnection object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of SensorChannelConnection object IDs
     * @return list of SensorChannelConnection object fields
     */
    idempotent SensorChannelConnectionFieldsList getSensorChannelConnectionFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all SensorChannelConnection objects matching the given
     * reference fields.
     *
     * @param fields SensorChannelConnection object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching SensorChannelConnection objects
     */
    idempotent IdList findEqualSensorChannelConnection(SensorChannelConnectionFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named SensorChannelConnection object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields SensorChannelConnection object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setSensorChannelConnectionFields(SensorChannelConnectionFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named SensorChannelConnection object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setSensorChannelConnectionFieldsList(SensorChannelConnectionFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FixedCamera object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFixedCamera(FixedCameraFields fields) throws ServerError;

    /**
     * Adds a set of FixedCamera objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFixedCameraList(FixedCameraFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FixedCamera object.
     *
     * @param id  FixedCamera object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFixedCamera(long id) throws ServerError;

    /**
     * Gets the FixedCamera object proxy.
     *
     * @param id  FixedCamera object ID
     * @return FixedCamera object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FixedCamera* getFixedCamera(long id) throws ServerError;

    /**
     * Gets a list of all FixedCamera object IDs.
     *
     * @return list of FixedCamera object IDs
     */
    idempotent IdList getFixedCameraIds() throws ServerError;

    /**
     * Gets a list of FixedCamera object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FixedCamera object IDs
     * @return list of FixedCamera object proxies
     */
    idempotent FixedCameraList getFixedCameraList(IdList ids) throws ServerError;

    /**
     * Gets the FixedCamera object fields.
     *
     * @param id FixedCamera object ID
     * @return FixedCamera object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FixedCameraFields getFixedCameraFields(long id) throws ServerError;

    /**
     * Gets a list of FixedCamera object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FixedCamera object IDs
     * @return list of FixedCamera object fields
     */
    idempotent FixedCameraFieldsList getFixedCameraFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FixedCamera objects matching the given
     * reference fields.
     *
     * @param fields FixedCamera object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FixedCamera objects
     */
    idempotent IdList findEqualFixedCamera(FixedCameraFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FixedCamera object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FixedCamera object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFixedCameraFields(FixedCameraFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FixedCamera object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFixedCameraFieldsList(FixedCameraFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a BridgeDetails object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addBridgeDetails(BridgeDetailsFields fields) throws ServerError;

    /**
     * Adds a set of BridgeDetails objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addBridgeDetailsList(BridgeDetailsFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified BridgeDetails object.
     *
     * @param id  BridgeDetails object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delBridgeDetails(long id) throws ServerError;

    /**
     * Gets the BridgeDetails object proxy.
     *
     * @param id  BridgeDetails object ID
     * @return BridgeDetails object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent BridgeDetails* getBridgeDetails(long id) throws ServerError;

    /**
     * Gets a list of all BridgeDetails object IDs.
     *
     * @return list of BridgeDetails object IDs
     */
    idempotent IdList getBridgeDetailsIds() throws ServerError;

    /**
     * Gets a list of BridgeDetails object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of BridgeDetails object IDs
     * @return list of BridgeDetails object proxies
     */
    idempotent BridgeDetailsList getBridgeDetailsList(IdList ids) throws ServerError;

    /**
     * Gets the BridgeDetails object fields.
     *
     * @param id BridgeDetails object ID
     * @return BridgeDetails object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent BridgeDetailsFields getBridgeDetailsFields(long id) throws ServerError;

    /**
     * Gets a list of BridgeDetails object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of BridgeDetails object IDs
     * @return list of BridgeDetails object fields
     */
    idempotent BridgeDetailsFieldsList getBridgeDetailsFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all BridgeDetails objects matching the given
     * reference fields.
     *
     * @param fields BridgeDetails object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching BridgeDetails objects
     */
    idempotent IdList findEqualBridgeDetails(BridgeDetailsFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named BridgeDetails object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields BridgeDetails object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setBridgeDetailsFields(BridgeDetailsFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named BridgeDetails object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setBridgeDetailsFieldsList(BridgeDetailsFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FacilityRoad object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFacilityRoad(FacilityRoadFields fields) throws ServerError;

    /**
     * Adds a set of FacilityRoad objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFacilityRoadList(FacilityRoadFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FacilityRoad object.
     *
     * @param id  FacilityRoad object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFacilityRoad(long id) throws ServerError;

    /**
     * Gets the FacilityRoad object proxy.
     *
     * @param id  FacilityRoad object ID
     * @return FacilityRoad object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FacilityRoad* getFacilityRoad(long id) throws ServerError;

    /**
     * Gets a list of all FacilityRoad object IDs.
     *
     * @return list of FacilityRoad object IDs
     */
    idempotent IdList getFacilityRoadIds() throws ServerError;

    /**
     * Gets a list of FacilityRoad object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FacilityRoad object IDs
     * @return list of FacilityRoad object proxies
     */
    idempotent FacilityRoadList getFacilityRoadList(IdList ids) throws ServerError;

    /**
     * Gets the FacilityRoad object fields.
     *
     * @param id FacilityRoad object ID
     * @return FacilityRoad object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FacilityRoadFields getFacilityRoadFields(long id) throws ServerError;

    /**
     * Gets a list of FacilityRoad object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FacilityRoad object IDs
     * @return list of FacilityRoad object fields
     */
    idempotent FacilityRoadFieldsList getFacilityRoadFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FacilityRoad objects matching the given
     * reference fields.
     *
     * @param fields FacilityRoad object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FacilityRoad objects
     */
    idempotent IdList findEqualFacilityRoad(FacilityRoadFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FacilityRoad object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FacilityRoad object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFacilityRoadFields(FacilityRoadFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FacilityRoad object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFacilityRoadFieldsList(FacilityRoadFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FacilityRailway object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFacilityRailway(FacilityRailwayFields fields) throws ServerError;

    /**
     * Adds a set of FacilityRailway objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFacilityRailwayList(FacilityRailwayFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FacilityRailway object.
     *
     * @param id  FacilityRailway object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFacilityRailway(long id) throws ServerError;

    /**
     * Gets the FacilityRailway object proxy.
     *
     * @param id  FacilityRailway object ID
     * @return FacilityRailway object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FacilityRailway* getFacilityRailway(long id) throws ServerError;

    /**
     * Gets a list of all FacilityRailway object IDs.
     *
     * @return list of FacilityRailway object IDs
     */
    idempotent IdList getFacilityRailwayIds() throws ServerError;

    /**
     * Gets a list of FacilityRailway object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FacilityRailway object IDs
     * @return list of FacilityRailway object proxies
     */
    idempotent FacilityRailwayList getFacilityRailwayList(IdList ids) throws ServerError;

    /**
     * Gets the FacilityRailway object fields.
     *
     * @param id FacilityRailway object ID
     * @return FacilityRailway object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FacilityRailwayFields getFacilityRailwayFields(long id) throws ServerError;

    /**
     * Gets a list of FacilityRailway object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FacilityRailway object IDs
     * @return list of FacilityRailway object fields
     */
    idempotent FacilityRailwayFieldsList getFacilityRailwayFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FacilityRailway objects matching the given
     * reference fields.
     *
     * @param fields FacilityRailway object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FacilityRailway objects
     */
    idempotent IdList findEqualFacilityRailway(FacilityRailwayFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FacilityRailway object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FacilityRailway object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFacilityRailwayFields(FacilityRailwayFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FacilityRailway object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFacilityRailwayFieldsList(FacilityRailwayFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FeatureRoad object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFeatureRoad(FeatureRoadFields fields) throws ServerError;

    /**
     * Adds a set of FeatureRoad objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFeatureRoadList(FeatureRoadFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FeatureRoad object.
     *
     * @param id  FeatureRoad object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFeatureRoad(long id) throws ServerError;

    /**
     * Gets the FeatureRoad object proxy.
     *
     * @param id  FeatureRoad object ID
     * @return FeatureRoad object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FeatureRoad* getFeatureRoad(long id) throws ServerError;

    /**
     * Gets a list of all FeatureRoad object IDs.
     *
     * @return list of FeatureRoad object IDs
     */
    idempotent IdList getFeatureRoadIds() throws ServerError;

    /**
     * Gets a list of FeatureRoad object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FeatureRoad object IDs
     * @return list of FeatureRoad object proxies
     */
    idempotent FeatureRoadList getFeatureRoadList(IdList ids) throws ServerError;

    /**
     * Gets the FeatureRoad object fields.
     *
     * @param id FeatureRoad object ID
     * @return FeatureRoad object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FeatureRoadFields getFeatureRoadFields(long id) throws ServerError;

    /**
     * Gets a list of FeatureRoad object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FeatureRoad object IDs
     * @return list of FeatureRoad object fields
     */
    idempotent FeatureRoadFieldsList getFeatureRoadFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FeatureRoad objects matching the given
     * reference fields.
     *
     * @param fields FeatureRoad object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FeatureRoad objects
     */
    idempotent IdList findEqualFeatureRoad(FeatureRoadFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FeatureRoad object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FeatureRoad object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFeatureRoadFields(FeatureRoadFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FeatureRoad object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFeatureRoadFieldsList(FeatureRoadFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FeatureRailway object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFeatureRailway(FeatureRailwayFields fields) throws ServerError;

    /**
     * Adds a set of FeatureRailway objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFeatureRailwayList(FeatureRailwayFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FeatureRailway object.
     *
     * @param id  FeatureRailway object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFeatureRailway(long id) throws ServerError;

    /**
     * Gets the FeatureRailway object proxy.
     *
     * @param id  FeatureRailway object ID
     * @return FeatureRailway object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FeatureRailway* getFeatureRailway(long id) throws ServerError;

    /**
     * Gets a list of all FeatureRailway object IDs.
     *
     * @return list of FeatureRailway object IDs
     */
    idempotent IdList getFeatureRailwayIds() throws ServerError;

    /**
     * Gets a list of FeatureRailway object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FeatureRailway object IDs
     * @return list of FeatureRailway object proxies
     */
    idempotent FeatureRailwayList getFeatureRailwayList(IdList ids) throws ServerError;

    /**
     * Gets the FeatureRailway object fields.
     *
     * @param id FeatureRailway object ID
     * @return FeatureRailway object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FeatureRailwayFields getFeatureRailwayFields(long id) throws ServerError;

    /**
     * Gets a list of FeatureRailway object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FeatureRailway object IDs
     * @return list of FeatureRailway object fields
     */
    idempotent FeatureRailwayFieldsList getFeatureRailwayFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FeatureRailway objects matching the given
     * reference fields.
     *
     * @param fields FeatureRailway object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FeatureRailway objects
     */
    idempotent IdList findEqualFeatureRailway(FeatureRailwayFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FeatureRailway object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FeatureRailway object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFeatureRailwayFields(FeatureRailwayFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FeatureRailway object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFeatureRailwayFieldsList(FeatureRailwayFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a FeatureRiver object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addFeatureRiver(FeatureRiverFields fields) throws ServerError;

    /**
     * Adds a set of FeatureRiver objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addFeatureRiverList(FeatureRiverFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified FeatureRiver object.
     *
     * @param id  FeatureRiver object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delFeatureRiver(long id) throws ServerError;

    /**
     * Gets the FeatureRiver object proxy.
     *
     * @param id  FeatureRiver object ID
     * @return FeatureRiver object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FeatureRiver* getFeatureRiver(long id) throws ServerError;

    /**
     * Gets a list of all FeatureRiver object IDs.
     *
     * @return list of FeatureRiver object IDs
     */
    idempotent IdList getFeatureRiverIds() throws ServerError;

    /**
     * Gets a list of FeatureRiver object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FeatureRiver object IDs
     * @return list of FeatureRiver object proxies
     */
    idempotent FeatureRiverList getFeatureRiverList(IdList ids) throws ServerError;

    /**
     * Gets the FeatureRiver object fields.
     *
     * @param id FeatureRiver object ID
     * @return FeatureRiver object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent FeatureRiverFields getFeatureRiverFields(long id) throws ServerError;

    /**
     * Gets a list of FeatureRiver object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of FeatureRiver object IDs
     * @return list of FeatureRiver object fields
     */
    idempotent FeatureRiverFieldsList getFeatureRiverFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all FeatureRiver objects matching the given
     * reference fields.
     *
     * @param fields FeatureRiver object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching FeatureRiver objects
     */
    idempotent IdList findEqualFeatureRiver(FeatureRiverFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FeatureRiver object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields FeatureRiver object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFeatureRiverFields(FeatureRiverFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named FeatureRiver object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setFeatureRiverFieldsList(FeatureRiverFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a Road object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addRoad(RoadFields fields) throws ServerError;

    /**
     * Adds a set of Road objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addRoadList(RoadFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified Road object.
     *
     * @param id  Road object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delRoad(long id) throws ServerError;

    /**
     * Gets the Road object proxy.
     *
     * @param id  Road object ID
     * @return Road object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent Road* getRoad(long id) throws ServerError;

    /**
     * Gets a list of all Road object IDs.
     *
     * @return list of Road object IDs
     */
    idempotent IdList getRoadIds() throws ServerError;

    /**
     * Gets a list of Road object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of Road object IDs
     * @return list of Road object proxies
     */
    idempotent RoadList getRoadList(IdList ids) throws ServerError;

    /**
     * Gets the Road object fields.
     *
     * @param id Road object ID
     * @return Road object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent RoadFields getRoadFields(long id) throws ServerError;

    /**
     * Gets a list of Road object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of Road object IDs
     * @return list of Road object fields
     */
    idempotent RoadFieldsList getRoadFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all Road objects matching the given
     * reference fields.
     *
     * @param fields Road object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching Road objects
     */
    idempotent IdList findEqualRoad(RoadFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named Road object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields Road object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setRoadFields(RoadFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named Road object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setRoadFieldsList(RoadFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a Railway object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addRailway(RailwayFields fields) throws ServerError;

    /**
     * Adds a set of Railway objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addRailwayList(RailwayFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified Railway object.
     *
     * @param id  Railway object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delRailway(long id) throws ServerError;

    /**
     * Gets the Railway object proxy.
     *
     * @param id  Railway object ID
     * @return Railway object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent Railway* getRailway(long id) throws ServerError;

    /**
     * Gets a list of all Railway object IDs.
     *
     * @return list of Railway object IDs
     */
    idempotent IdList getRailwayIds() throws ServerError;

    /**
     * Gets a list of Railway object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of Railway object IDs
     * @return list of Railway object proxies
     */
    idempotent RailwayList getRailwayList(IdList ids) throws ServerError;

    /**
     * Gets the Railway object fields.
     *
     * @param id Railway object ID
     * @return Railway object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent RailwayFields getRailwayFields(long id) throws ServerError;

    /**
     * Gets a list of Railway object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of Railway object IDs
     * @return list of Railway object fields
     */
    idempotent RailwayFieldsList getRailwayFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all Railway objects matching the given
     * reference fields.
     *
     * @param fields Railway object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching Railway objects
     */
    idempotent IdList findEqualRailway(RailwayFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named Railway object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields Railway object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setRailwayFields(RailwayFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named Railway object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setRailwayFieldsList(RailwayFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a River object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addRiver(RiverFields fields) throws ServerError;

    /**
     * Adds a set of River objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addRiverList(RiverFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified River object.
     *
     * @param id  River object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delRiver(long id) throws ServerError;

    /**
     * Gets the River object proxy.
     *
     * @param id  River object ID
     * @return River object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent River* getRiver(long id) throws ServerError;

    /**
     * Gets a list of all River object IDs.
     *
     * @return list of River object IDs
     */
    idempotent IdList getRiverIds() throws ServerError;

    /**
     * Gets a list of River object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of River object IDs
     * @return list of River object proxies
     */
    idempotent RiverList getRiverList(IdList ids) throws ServerError;

    /**
     * Gets the River object fields.
     *
     * @param id River object ID
     * @return River object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent RiverFields getRiverFields(long id) throws ServerError;

    /**
     * Gets a list of River object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of River object IDs
     * @return list of River object fields
     */
    idempotent RiverFieldsList getRiverFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all River objects matching the given
     * reference fields.
     *
     * @param fields River object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching River objects
     */
    idempotent IdList findEqualRiver(RiverFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named River object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields River object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setRiverFields(RiverFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named River object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setRiverFieldsList(RiverFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a BridgeInspection object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addBridgeInspection(BridgeInspectionFields fields) throws ServerError;

    /**
     * Adds a set of BridgeInspection objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addBridgeInspectionList(BridgeInspectionFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified BridgeInspection object.
     *
     * @param id  BridgeInspection object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delBridgeInspection(long id) throws ServerError;

    /**
     * Gets the BridgeInspection object proxy.
     *
     * @param id  BridgeInspection object ID
     * @return BridgeInspection object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent BridgeInspection* getBridgeInspection(long id) throws ServerError;

    /**
     * Gets a list of all BridgeInspection object IDs.
     *
     * @return list of BridgeInspection object IDs
     */
    idempotent IdList getBridgeInspectionIds() throws ServerError;

    /**
     * Gets a list of BridgeInspection object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of BridgeInspection object IDs
     * @return list of BridgeInspection object proxies
     */
    idempotent BridgeInspectionList getBridgeInspectionList(IdList ids) throws ServerError;

    /**
     * Gets the BridgeInspection object fields.
     *
     * @param id BridgeInspection object ID
     * @return BridgeInspection object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent BridgeInspectionFields getBridgeInspectionFields(long id) throws ServerError;

    /**
     * Gets a list of BridgeInspection object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of BridgeInspection object IDs
     * @return list of BridgeInspection object fields
     */
    idempotent BridgeInspectionFieldsList getBridgeInspectionFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all BridgeInspection objects matching the given
     * reference fields.
     *
     * @param fields BridgeInspection object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching BridgeInspection objects
     */
    idempotent IdList findEqualBridgeInspection(BridgeInspectionFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named BridgeInspection object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields BridgeInspection object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setBridgeInspectionFields(BridgeInspectionFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named BridgeInspection object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setBridgeInspectionFieldsList(BridgeInspectionFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a Inspector object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addInspector(InspectorFields fields) throws ServerError;

    /**
     * Adds a set of Inspector objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addInspectorList(InspectorFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified Inspector object.
     *
     * @param id  Inspector object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delInspector(long id) throws ServerError;

    /**
     * Gets the Inspector object proxy.
     *
     * @param id  Inspector object ID
     * @return Inspector object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent Inspector* getInspector(long id) throws ServerError;

    /**
     * Gets a list of all Inspector object IDs.
     *
     * @return list of Inspector object IDs
     */
    idempotent IdList getInspectorIds() throws ServerError;

    /**
     * Gets a list of Inspector object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of Inspector object IDs
     * @return list of Inspector object proxies
     */
    idempotent InspectorList getInspectorList(IdList ids) throws ServerError;

    /**
     * Gets the Inspector object fields.
     *
     * @param id Inspector object ID
     * @return Inspector object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent InspectorFields getInspectorFields(long id) throws ServerError;

    /**
     * Gets a list of Inspector object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of Inspector object IDs
     * @return list of Inspector object fields
     */
    idempotent InspectorFieldsList getInspectorFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all Inspector objects matching the given
     * reference fields.
     *
     * @param fields Inspector object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching Inspector objects
     */
    idempotent IdList findEqualInspector(InspectorFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named Inspector object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields Inspector object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setInspectorFields(InspectorFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named Inspector object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setInspectorFieldsList(InspectorFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a InspectionAgency object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addInspectionAgency(InspectionAgencyFields fields) throws ServerError;

    /**
     * Adds a set of InspectionAgency objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addInspectionAgencyList(InspectionAgencyFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified InspectionAgency object.
     *
     * @param id  InspectionAgency object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delInspectionAgency(long id) throws ServerError;

    /**
     * Gets the InspectionAgency object proxy.
     *
     * @param id  InspectionAgency object ID
     * @return InspectionAgency object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent InspectionAgency* getInspectionAgency(long id) throws ServerError;

    /**
     * Gets a list of all InspectionAgency object IDs.
     *
     * @return list of InspectionAgency object IDs
     */
    idempotent IdList getInspectionAgencyIds() throws ServerError;

    /**
     * Gets a list of InspectionAgency object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of InspectionAgency object IDs
     * @return list of InspectionAgency object proxies
     */
    idempotent InspectionAgencyList getInspectionAgencyList(IdList ids) throws ServerError;

    /**
     * Gets the InspectionAgency object fields.
     *
     * @param id InspectionAgency object ID
     * @return InspectionAgency object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent InspectionAgencyFields getInspectionAgencyFields(long id) throws ServerError;

    /**
     * Gets a list of InspectionAgency object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of InspectionAgency object IDs
     * @return list of InspectionAgency object fields
     */
    idempotent InspectionAgencyFieldsList getInspectionAgencyFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all InspectionAgency objects matching the given
     * reference fields.
     *
     * @param fields InspectionAgency object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching InspectionAgency objects
     */
    idempotent IdList findEqualInspectionAgency(InspectionAgencyFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named InspectionAgency object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields InspectionAgency object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setInspectionAgencyFields(InspectionAgencyFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named InspectionAgency object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setInspectionAgencyFieldsList(InspectionAgencyFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a StructureAssessment object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addStructureAssessment(StructureAssessmentFields fields) throws ServerError;

    /**
     * Adds a set of StructureAssessment objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addStructureAssessmentList(StructureAssessmentFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified StructureAssessment object.
     *
     * @param id  StructureAssessment object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delStructureAssessment(long id) throws ServerError;

    /**
     * Gets the StructureAssessment object proxy.
     *
     * @param id  StructureAssessment object ID
     * @return StructureAssessment object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent StructureAssessment* getStructureAssessment(long id) throws ServerError;

    /**
     * Gets a list of all StructureAssessment object IDs.
     *
     * @return list of StructureAssessment object IDs
     */
    idempotent IdList getStructureAssessmentIds() throws ServerError;

    /**
     * Gets a list of StructureAssessment object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of StructureAssessment object IDs
     * @return list of StructureAssessment object proxies
     */
    idempotent StructureAssessmentList getStructureAssessmentList(IdList ids) throws ServerError;

    /**
     * Gets the StructureAssessment object fields.
     *
     * @param id StructureAssessment object ID
     * @return StructureAssessment object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent StructureAssessmentFields getStructureAssessmentFields(long id) throws ServerError;

    /**
     * Gets a list of StructureAssessment object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of StructureAssessment object IDs
     * @return list of StructureAssessment object fields
     */
    idempotent StructureAssessmentFieldsList getStructureAssessmentFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all StructureAssessment objects matching the given
     * reference fields.
     *
     * @param fields StructureAssessment object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching StructureAssessment objects
     */
    idempotent IdList findEqualStructureAssessment(StructureAssessmentFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named StructureAssessment object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields StructureAssessment object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setStructureAssessmentFields(StructureAssessmentFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named StructureAssessment object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setStructureAssessmentFieldsList(StructureAssessmentFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a StructureRetrofit object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addStructureRetrofit(StructureRetrofitFields fields) throws ServerError;

    /**
     * Adds a set of StructureRetrofit objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addStructureRetrofitList(StructureRetrofitFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified StructureRetrofit object.
     *
     * @param id  StructureRetrofit object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delStructureRetrofit(long id) throws ServerError;

    /**
     * Gets the StructureRetrofit object proxy.
     *
     * @param id  StructureRetrofit object ID
     * @return StructureRetrofit object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent StructureRetrofit* getStructureRetrofit(long id) throws ServerError;

    /**
     * Gets a list of all StructureRetrofit object IDs.
     *
     * @return list of StructureRetrofit object IDs
     */
    idempotent IdList getStructureRetrofitIds() throws ServerError;

    /**
     * Gets a list of StructureRetrofit object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of StructureRetrofit object IDs
     * @return list of StructureRetrofit object proxies
     */
    idempotent StructureRetrofitList getStructureRetrofitList(IdList ids) throws ServerError;

    /**
     * Gets the StructureRetrofit object fields.
     *
     * @param id StructureRetrofit object ID
     * @return StructureRetrofit object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent StructureRetrofitFields getStructureRetrofitFields(long id) throws ServerError;

    /**
     * Gets a list of StructureRetrofit object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of StructureRetrofit object IDs
     * @return list of StructureRetrofit object fields
     */
    idempotent StructureRetrofitFieldsList getStructureRetrofitFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all StructureRetrofit objects matching the given
     * reference fields.
     *
     * @param fields StructureRetrofit object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching StructureRetrofit objects
     */
    idempotent IdList findEqualStructureRetrofit(StructureRetrofitFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named StructureRetrofit object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields StructureRetrofit object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setStructureRetrofitFields(StructureRetrofitFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named StructureRetrofit object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setStructureRetrofitFieldsList(StructureRetrofitFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a PontisElement object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addPontisElement(PontisElementFields fields) throws ServerError;

    /**
     * Adds a set of PontisElement objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addPontisElementList(PontisElementFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified PontisElement object.
     *
     * @param id  PontisElement object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delPontisElement(long id) throws ServerError;

    /**
     * Gets the PontisElement object proxy.
     *
     * @param id  PontisElement object ID
     * @return PontisElement object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent PontisElement* getPontisElement(long id) throws ServerError;

    /**
     * Gets a list of all PontisElement object IDs.
     *
     * @return list of PontisElement object IDs
     */
    idempotent IdList getPontisElementIds() throws ServerError;

    /**
     * Gets a list of PontisElement object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of PontisElement object IDs
     * @return list of PontisElement object proxies
     */
    idempotent PontisElementList getPontisElementList(IdList ids) throws ServerError;

    /**
     * Gets the PontisElement object fields.
     *
     * @param id PontisElement object ID
     * @return PontisElement object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent PontisElementFields getPontisElementFields(long id) throws ServerError;

    /**
     * Gets a list of PontisElement object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of PontisElement object IDs
     * @return list of PontisElement object fields
     */
    idempotent PontisElementFieldsList getPontisElementFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all PontisElement objects matching the given
     * reference fields.
     *
     * @param fields PontisElement object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching PontisElement objects
     */
    idempotent IdList findEqualPontisElement(PontisElementFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named PontisElement object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields PontisElement object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setPontisElementFields(PontisElementFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named PontisElement object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setPontisElementFieldsList(PontisElementFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a StructureComponent object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addStructureComponent(StructureComponentFields fields) throws ServerError;

    /**
     * Adds a set of StructureComponent objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addStructureComponentList(StructureComponentFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified StructureComponent object.
     *
     * @param id  StructureComponent object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delStructureComponent(long id) throws ServerError;

    /**
     * Gets the StructureComponent object proxy.
     *
     * @param id  StructureComponent object ID
     * @return StructureComponent object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent StructureComponent* getStructureComponent(long id) throws ServerError;

    /**
     * Gets a list of all StructureComponent object IDs.
     *
     * @return list of StructureComponent object IDs
     */
    idempotent IdList getStructureComponentIds() throws ServerError;

    /**
     * Gets a list of StructureComponent object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of StructureComponent object IDs
     * @return list of StructureComponent object proxies
     */
    idempotent StructureComponentList getStructureComponentList(IdList ids) throws ServerError;

    /**
     * Gets the StructureComponent object fields.
     *
     * @param id StructureComponent object ID
     * @return StructureComponent object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent StructureComponentFields getStructureComponentFields(long id) throws ServerError;

    /**
     * Gets a list of StructureComponent object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of StructureComponent object IDs
     * @return list of StructureComponent object fields
     */
    idempotent StructureComponentFieldsList getStructureComponentFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all StructureComponent objects matching the given
     * reference fields.
     *
     * @param fields StructureComponent object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching StructureComponent objects
     */
    idempotent IdList findEqualStructureComponent(StructureComponentFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named StructureComponent object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields StructureComponent object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setStructureComponentFields(StructureComponentFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named StructureComponent object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setStructureComponentFieldsList(StructureComponentFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a ComponentInspElement object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addComponentInspElement(ComponentInspElementFields fields) throws ServerError;

    /**
     * Adds a set of ComponentInspElement objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addComponentInspElementList(ComponentInspElementFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified ComponentInspElement object.
     *
     * @param id  ComponentInspElement object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delComponentInspElement(long id) throws ServerError;

    /**
     * Gets the ComponentInspElement object proxy.
     *
     * @param id  ComponentInspElement object ID
     * @return ComponentInspElement object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent ComponentInspElement* getComponentInspElement(long id) throws ServerError;

    /**
     * Gets a list of all ComponentInspElement object IDs.
     *
     * @return list of ComponentInspElement object IDs
     */
    idempotent IdList getComponentInspElementIds() throws ServerError;

    /**
     * Gets a list of ComponentInspElement object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of ComponentInspElement object IDs
     * @return list of ComponentInspElement object proxies
     */
    idempotent ComponentInspElementList getComponentInspElementList(IdList ids) throws ServerError;

    /**
     * Gets the ComponentInspElement object fields.
     *
     * @param id ComponentInspElement object ID
     * @return ComponentInspElement object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent ComponentInspElementFields getComponentInspElementFields(long id) throws ServerError;

    /**
     * Gets a list of ComponentInspElement object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of ComponentInspElement object IDs
     * @return list of ComponentInspElement object fields
     */
    idempotent ComponentInspElementFieldsList getComponentInspElementFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all ComponentInspElement objects matching the given
     * reference fields.
     *
     * @param fields ComponentInspElement object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching ComponentInspElement objects
     */
    idempotent IdList findEqualComponentInspElement(ComponentInspElementFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named ComponentInspElement object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields ComponentInspElement object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setComponentInspElementFields(ComponentInspElementFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named ComponentInspElement object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setComponentInspElementFieldsList(ComponentInspElementFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a StructureComponentGroups object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addStructureComponentGroups(StructureComponentGroupsFields fields) throws ServerError;

    /**
     * Adds a set of StructureComponentGroups objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addStructureComponentGroupsList(StructureComponentGroupsFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified StructureComponentGroups object.
     *
     * @param id  StructureComponentGroups object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delStructureComponentGroups(long id) throws ServerError;

    /**
     * Gets the StructureComponentGroups object proxy.
     *
     * @param id  StructureComponentGroups object ID
     * @return StructureComponentGroups object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent StructureComponentGroups* getStructureComponentGroups(long id) throws ServerError;

    /**
     * Gets a list of all StructureComponentGroups object IDs.
     *
     * @return list of StructureComponentGroups object IDs
     */
    idempotent IdList getStructureComponentGroupsIds() throws ServerError;

    /**
     * Gets a list of StructureComponentGroups object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of StructureComponentGroups object IDs
     * @return list of StructureComponentGroups object proxies
     */
    idempotent StructureComponentGroupsList getStructureComponentGroupsList(IdList ids) throws ServerError;

    /**
     * Gets the StructureComponentGroups object fields.
     *
     * @param id StructureComponentGroups object ID
     * @return StructureComponentGroups object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent StructureComponentGroupsFields getStructureComponentGroupsFields(long id) throws ServerError;

    /**
     * Gets a list of StructureComponentGroups object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of StructureComponentGroups object IDs
     * @return list of StructureComponentGroups object fields
     */
    idempotent StructureComponentGroupsFieldsList getStructureComponentGroupsFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all StructureComponentGroups objects matching the given
     * reference fields.
     *
     * @param fields StructureComponentGroups object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching StructureComponentGroups objects
     */
    idempotent IdList findEqualStructureComponentGroups(StructureComponentGroupsFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named StructureComponentGroups object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields StructureComponentGroups object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setStructureComponentGroupsFields(StructureComponentGroupsFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named StructureComponentGroups object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setStructureComponentGroupsFieldsList(StructureComponentGroupsFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a StructureComponentReliability object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addStructureComponentReliability(StructureComponentReliabilityFields fields) throws ServerError;

    /**
     * Adds a set of StructureComponentReliability objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addStructureComponentReliabilityList(StructureComponentReliabilityFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified StructureComponentReliability object.
     *
     * @param id  StructureComponentReliability object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delStructureComponentReliability(long id) throws ServerError;

    /**
     * Gets the StructureComponentReliability object proxy.
     *
     * @param id  StructureComponentReliability object ID
     * @return StructureComponentReliability object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent StructureComponentReliability* getStructureComponentReliability(long id) throws ServerError;

    /**
     * Gets a list of all StructureComponentReliability object IDs.
     *
     * @return list of StructureComponentReliability object IDs
     */
    idempotent IdList getStructureComponentReliabilityIds() throws ServerError;

    /**
     * Gets a list of StructureComponentReliability object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of StructureComponentReliability object IDs
     * @return list of StructureComponentReliability object proxies
     */
    idempotent StructureComponentReliabilityList getStructureComponentReliabilityList(IdList ids) throws ServerError;

    /**
     * Gets the StructureComponentReliability object fields.
     *
     * @param id StructureComponentReliability object ID
     * @return StructureComponentReliability object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent StructureComponentReliabilityFields getStructureComponentReliabilityFields(long id) throws ServerError;

    /**
     * Gets a list of StructureComponentReliability object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of StructureComponentReliability object IDs
     * @return list of StructureComponentReliability object fields
     */
    idempotent StructureComponentReliabilityFieldsList getStructureComponentReliabilityFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all StructureComponentReliability objects matching the given
     * reference fields.
     *
     * @param fields StructureComponentReliability object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching StructureComponentReliability objects
     */
    idempotent IdList findEqualStructureComponentReliability(StructureComponentReliabilityFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named StructureComponentReliability object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields StructureComponentReliability object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setStructureComponentReliabilityFields(StructureComponentReliabilityFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named StructureComponentReliability object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setStructureComponentReliabilityFieldsList(StructureComponentReliabilityFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a StructureComponentAssessment object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addStructureComponentAssessment(StructureComponentAssessmentFields fields) throws ServerError;

    /**
     * Adds a set of StructureComponentAssessment objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addStructureComponentAssessmentList(StructureComponentAssessmentFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified StructureComponentAssessment object.
     *
     * @param id  StructureComponentAssessment object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delStructureComponentAssessment(long id) throws ServerError;

    /**
     * Gets the StructureComponentAssessment object proxy.
     *
     * @param id  StructureComponentAssessment object ID
     * @return StructureComponentAssessment object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent StructureComponentAssessment* getStructureComponentAssessment(long id) throws ServerError;

    /**
     * Gets a list of all StructureComponentAssessment object IDs.
     *
     * @return list of StructureComponentAssessment object IDs
     */
    idempotent IdList getStructureComponentAssessmentIds() throws ServerError;

    /**
     * Gets a list of StructureComponentAssessment object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of StructureComponentAssessment object IDs
     * @return list of StructureComponentAssessment object proxies
     */
    idempotent StructureComponentAssessmentList getStructureComponentAssessmentList(IdList ids) throws ServerError;

    /**
     * Gets the StructureComponentAssessment object fields.
     *
     * @param id StructureComponentAssessment object ID
     * @return StructureComponentAssessment object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent StructureComponentAssessmentFields getStructureComponentAssessmentFields(long id) throws ServerError;

    /**
     * Gets a list of StructureComponentAssessment object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of StructureComponentAssessment object IDs
     * @return list of StructureComponentAssessment object fields
     */
    idempotent StructureComponentAssessmentFieldsList getStructureComponentAssessmentFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all StructureComponentAssessment objects matching the given
     * reference fields.
     *
     * @param fields StructureComponentAssessment object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching StructureComponentAssessment objects
     */
    idempotent IdList findEqualStructureComponentAssessment(StructureComponentAssessmentFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named StructureComponentAssessment object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields StructureComponentAssessment object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setStructureComponentAssessmentFields(StructureComponentAssessmentFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named StructureComponentAssessment object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setStructureComponentAssessmentFieldsList(StructureComponentAssessmentFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a StructureComponentRating object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addStructureComponentRating(StructureComponentRatingFields fields) throws ServerError;

    /**
     * Adds a set of StructureComponentRating objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addStructureComponentRatingList(StructureComponentRatingFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified StructureComponentRating object.
     *
     * @param id  StructureComponentRating object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delStructureComponentRating(long id) throws ServerError;

    /**
     * Gets the StructureComponentRating object proxy.
     *
     * @param id  StructureComponentRating object ID
     * @return StructureComponentRating object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent StructureComponentRating* getStructureComponentRating(long id) throws ServerError;

    /**
     * Gets a list of all StructureComponentRating object IDs.
     *
     * @return list of StructureComponentRating object IDs
     */
    idempotent IdList getStructureComponentRatingIds() throws ServerError;

    /**
     * Gets a list of StructureComponentRating object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of StructureComponentRating object IDs
     * @return list of StructureComponentRating object proxies
     */
    idempotent StructureComponentRatingList getStructureComponentRatingList(IdList ids) throws ServerError;

    /**
     * Gets the StructureComponentRating object fields.
     *
     * @param id StructureComponentRating object ID
     * @return StructureComponentRating object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent StructureComponentRatingFields getStructureComponentRatingFields(long id) throws ServerError;

    /**
     * Gets a list of StructureComponentRating object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of StructureComponentRating object IDs
     * @return list of StructureComponentRating object fields
     */
    idempotent StructureComponentRatingFieldsList getStructureComponentRatingFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all StructureComponentRating objects matching the given
     * reference fields.
     *
     * @param fields StructureComponentRating object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching StructureComponentRating objects
     */
    idempotent IdList findEqualStructureComponentRating(StructureComponentRatingFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named StructureComponentRating object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields StructureComponentRating object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setStructureComponentRatingFields(StructureComponentRatingFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named StructureComponentRating object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setStructureComponentRatingFieldsList(StructureComponentRatingFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a StructureComponentRepairOption object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addStructureComponentRepairOption(StructureComponentRepairOptionFields fields) throws ServerError;

    /**
     * Adds a set of StructureComponentRepairOption objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addStructureComponentRepairOptionList(StructureComponentRepairOptionFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified StructureComponentRepairOption object.
     *
     * @param id  StructureComponentRepairOption object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delStructureComponentRepairOption(long id) throws ServerError;

    /**
     * Gets the StructureComponentRepairOption object proxy.
     *
     * @param id  StructureComponentRepairOption object ID
     * @return StructureComponentRepairOption object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent StructureComponentRepairOption* getStructureComponentRepairOption(long id) throws ServerError;

    /**
     * Gets a list of all StructureComponentRepairOption object IDs.
     *
     * @return list of StructureComponentRepairOption object IDs
     */
    idempotent IdList getStructureComponentRepairOptionIds() throws ServerError;

    /**
     * Gets a list of StructureComponentRepairOption object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of StructureComponentRepairOption object IDs
     * @return list of StructureComponentRepairOption object proxies
     */
    idempotent StructureComponentRepairOptionList getStructureComponentRepairOptionList(IdList ids) throws ServerError;

    /**
     * Gets the StructureComponentRepairOption object fields.
     *
     * @param id StructureComponentRepairOption object ID
     * @return StructureComponentRepairOption object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent StructureComponentRepairOptionFields getStructureComponentRepairOptionFields(long id) throws ServerError;

    /**
     * Gets a list of StructureComponentRepairOption object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of StructureComponentRepairOption object IDs
     * @return list of StructureComponentRepairOption object fields
     */
    idempotent StructureComponentRepairOptionFieldsList getStructureComponentRepairOptionFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all StructureComponentRepairOption objects matching the given
     * reference fields.
     *
     * @param fields StructureComponentRepairOption object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching StructureComponentRepairOption objects
     */
    idempotent IdList findEqualStructureComponentRepairOption(StructureComponentRepairOptionFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named StructureComponentRepairOption object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields StructureComponentRepairOption object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setStructureComponentRepairOptionFields(StructureComponentRepairOptionFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named StructureComponentRepairOption object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setStructureComponentRepairOptionFieldsList(StructureComponentRepairOptionFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a StructureTraffic object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addStructureTraffic(StructureTrafficFields fields) throws ServerError;

    /**
     * Adds a set of StructureTraffic objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addStructureTrafficList(StructureTrafficFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified StructureTraffic object.
     *
     * @param id  StructureTraffic object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delStructureTraffic(long id) throws ServerError;

    /**
     * Gets the StructureTraffic object proxy.
     *
     * @param id  StructureTraffic object ID
     * @return StructureTraffic object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent StructureTraffic* getStructureTraffic(long id) throws ServerError;

    /**
     * Gets a list of all StructureTraffic object IDs.
     *
     * @return list of StructureTraffic object IDs
     */
    idempotent IdList getStructureTrafficIds() throws ServerError;

    /**
     * Gets a list of StructureTraffic object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of StructureTraffic object IDs
     * @return list of StructureTraffic object proxies
     */
    idempotent StructureTrafficList getStructureTrafficList(IdList ids) throws ServerError;

    /**
     * Gets the StructureTraffic object fields.
     *
     * @param id StructureTraffic object ID
     * @return StructureTraffic object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent StructureTrafficFields getStructureTrafficFields(long id) throws ServerError;

    /**
     * Gets a list of StructureTraffic object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of StructureTraffic object IDs
     * @return list of StructureTraffic object fields
     */
    idempotent StructureTrafficFieldsList getStructureTrafficFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all StructureTraffic objects matching the given
     * reference fields.
     *
     * @param fields StructureTraffic object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching StructureTraffic objects
     */
    idempotent IdList findEqualStructureTraffic(StructureTrafficFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named StructureTraffic object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields StructureTraffic object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setStructureTrafficFields(StructureTrafficFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named StructureTraffic object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setStructureTrafficFieldsList(StructureTrafficFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a StructureComponentRepair object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addStructureComponentRepair(StructureComponentRepairFields fields) throws ServerError;

    /**
     * Adds a set of StructureComponentRepair objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addStructureComponentRepairList(StructureComponentRepairFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified StructureComponentRepair object.
     *
     * @param id  StructureComponentRepair object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delStructureComponentRepair(long id) throws ServerError;

    /**
     * Gets the StructureComponentRepair object proxy.
     *
     * @param id  StructureComponentRepair object ID
     * @return StructureComponentRepair object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent StructureComponentRepair* getStructureComponentRepair(long id) throws ServerError;

    /**
     * Gets a list of all StructureComponentRepair object IDs.
     *
     * @return list of StructureComponentRepair object IDs
     */
    idempotent IdList getStructureComponentRepairIds() throws ServerError;

    /**
     * Gets a list of StructureComponentRepair object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of StructureComponentRepair object IDs
     * @return list of StructureComponentRepair object proxies
     */
    idempotent StructureComponentRepairList getStructureComponentRepairList(IdList ids) throws ServerError;

    /**
     * Gets the StructureComponentRepair object fields.
     *
     * @param id StructureComponentRepair object ID
     * @return StructureComponentRepair object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent StructureComponentRepairFields getStructureComponentRepairFields(long id) throws ServerError;

    /**
     * Gets a list of StructureComponentRepair object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of StructureComponentRepair object IDs
     * @return list of StructureComponentRepair object fields
     */
    idempotent StructureComponentRepairFieldsList getStructureComponentRepairFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all StructureComponentRepair objects matching the given
     * reference fields.
     *
     * @param fields StructureComponentRepair object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching StructureComponentRepair objects
     */
    idempotent IdList findEqualStructureComponentRepair(StructureComponentRepairFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named StructureComponentRepair object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields StructureComponentRepair object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setStructureComponentRepairFields(StructureComponentRepairFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named StructureComponentRepair object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setStructureComponentRepairFieldsList(StructureComponentRepairFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a ComponentInspElementAssessment object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addComponentInspElementAssessment(ComponentInspElementAssessmentFields fields) throws ServerError;

    /**
     * Adds a set of ComponentInspElementAssessment objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addComponentInspElementAssessmentList(ComponentInspElementAssessmentFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified ComponentInspElementAssessment object.
     *
     * @param id  ComponentInspElementAssessment object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delComponentInspElementAssessment(long id) throws ServerError;

    /**
     * Gets the ComponentInspElementAssessment object proxy.
     *
     * @param id  ComponentInspElementAssessment object ID
     * @return ComponentInspElementAssessment object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent ComponentInspElementAssessment* getComponentInspElementAssessment(long id) throws ServerError;

    /**
     * Gets a list of all ComponentInspElementAssessment object IDs.
     *
     * @return list of ComponentInspElementAssessment object IDs
     */
    idempotent IdList getComponentInspElementAssessmentIds() throws ServerError;

    /**
     * Gets a list of ComponentInspElementAssessment object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of ComponentInspElementAssessment object IDs
     * @return list of ComponentInspElementAssessment object proxies
     */
    idempotent ComponentInspElementAssessmentList getComponentInspElementAssessmentList(IdList ids) throws ServerError;

    /**
     * Gets the ComponentInspElementAssessment object fields.
     *
     * @param id ComponentInspElementAssessment object ID
     * @return ComponentInspElementAssessment object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent ComponentInspElementAssessmentFields getComponentInspElementAssessmentFields(long id) throws ServerError;

    /**
     * Gets a list of ComponentInspElementAssessment object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of ComponentInspElementAssessment object IDs
     * @return list of ComponentInspElementAssessment object fields
     */
    idempotent ComponentInspElementAssessmentFieldsList getComponentInspElementAssessmentFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all ComponentInspElementAssessment objects matching the given
     * reference fields.
     *
     * @param fields ComponentInspElementAssessment object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching ComponentInspElementAssessment objects
     */
    idempotent IdList findEqualComponentInspElementAssessment(ComponentInspElementAssessmentFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named ComponentInspElementAssessment object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields ComponentInspElementAssessment object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setComponentInspElementAssessmentFields(ComponentInspElementAssessmentFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named ComponentInspElementAssessment object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setComponentInspElementAssessmentFieldsList(ComponentInspElementAssessmentFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a InspectionMultimedia object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addInspectionMultimedia(InspectionMultimediaFields fields) throws ServerError;

    /**
     * Adds a set of InspectionMultimedia objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addInspectionMultimediaList(InspectionMultimediaFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified InspectionMultimedia object.
     *
     * @param id  InspectionMultimedia object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delInspectionMultimedia(long id) throws ServerError;

    /**
     * Gets the InspectionMultimedia object proxy.
     *
     * @param id  InspectionMultimedia object ID
     * @return InspectionMultimedia object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent InspectionMultimedia* getInspectionMultimedia(long id) throws ServerError;

    /**
     * Gets a list of all InspectionMultimedia object IDs.
     *
     * @return list of InspectionMultimedia object IDs
     */
    idempotent IdList getInspectionMultimediaIds() throws ServerError;

    /**
     * Gets a list of InspectionMultimedia object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of InspectionMultimedia object IDs
     * @return list of InspectionMultimedia object proxies
     */
    idempotent InspectionMultimediaList getInspectionMultimediaList(IdList ids) throws ServerError;

    /**
     * Gets the InspectionMultimedia object fields.
     *
     * @param id InspectionMultimedia object ID
     * @return InspectionMultimedia object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent InspectionMultimediaFields getInspectionMultimediaFields(long id) throws ServerError;

    /**
     * Gets a list of InspectionMultimedia object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of InspectionMultimedia object IDs
     * @return list of InspectionMultimedia object fields
     */
    idempotent InspectionMultimediaFieldsList getInspectionMultimediaFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all InspectionMultimedia objects matching the given
     * reference fields.
     *
     * @param fields InspectionMultimedia object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching InspectionMultimedia objects
     */
    idempotent IdList findEqualInspectionMultimedia(InspectionMultimediaFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named InspectionMultimedia object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields InspectionMultimedia object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setInspectionMultimediaFields(InspectionMultimediaFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named InspectionMultimedia object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setInspectionMultimediaFieldsList(InspectionMultimediaFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a BridgeInspectionMultimedia object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addBridgeInspectionMultimedia(BridgeInspectionMultimediaFields fields) throws ServerError;

    /**
     * Adds a set of BridgeInspectionMultimedia objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addBridgeInspectionMultimediaList(BridgeInspectionMultimediaFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified BridgeInspectionMultimedia object.
     *
     * @param id  BridgeInspectionMultimedia object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delBridgeInspectionMultimedia(long id) throws ServerError;

    /**
     * Gets the BridgeInspectionMultimedia object proxy.
     *
     * @param id  BridgeInspectionMultimedia object ID
     * @return BridgeInspectionMultimedia object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent BridgeInspectionMultimedia* getBridgeInspectionMultimedia(long id) throws ServerError;

    /**
     * Gets a list of all BridgeInspectionMultimedia object IDs.
     *
     * @return list of BridgeInspectionMultimedia object IDs
     */
    idempotent IdList getBridgeInspectionMultimediaIds() throws ServerError;

    /**
     * Gets a list of BridgeInspectionMultimedia object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of BridgeInspectionMultimedia object IDs
     * @return list of BridgeInspectionMultimedia object proxies
     */
    idempotent BridgeInspectionMultimediaList getBridgeInspectionMultimediaList(IdList ids) throws ServerError;

    /**
     * Gets the BridgeInspectionMultimedia object fields.
     *
     * @param id BridgeInspectionMultimedia object ID
     * @return BridgeInspectionMultimedia object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent BridgeInspectionMultimediaFields getBridgeInspectionMultimediaFields(long id) throws ServerError;

    /**
     * Gets a list of BridgeInspectionMultimedia object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of BridgeInspectionMultimedia object IDs
     * @return list of BridgeInspectionMultimedia object fields
     */
    idempotent BridgeInspectionMultimediaFieldsList getBridgeInspectionMultimediaFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all BridgeInspectionMultimedia objects matching the given
     * reference fields.
     *
     * @param fields BridgeInspectionMultimedia object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching BridgeInspectionMultimedia objects
     */
    idempotent IdList findEqualBridgeInspectionMultimedia(BridgeInspectionMultimediaFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named BridgeInspectionMultimedia object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields BridgeInspectionMultimedia object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setBridgeInspectionMultimediaFields(BridgeInspectionMultimediaFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named BridgeInspectionMultimedia object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setBridgeInspectionMultimediaFieldsList(BridgeInspectionMultimediaFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a ComponentInspectionMultimedia object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addComponentInspectionMultimedia(ComponentInspectionMultimediaFields fields) throws ServerError;

    /**
     * Adds a set of ComponentInspectionMultimedia objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addComponentInspectionMultimediaList(ComponentInspectionMultimediaFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified ComponentInspectionMultimedia object.
     *
     * @param id  ComponentInspectionMultimedia object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delComponentInspectionMultimedia(long id) throws ServerError;

    /**
     * Gets the ComponentInspectionMultimedia object proxy.
     *
     * @param id  ComponentInspectionMultimedia object ID
     * @return ComponentInspectionMultimedia object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent ComponentInspectionMultimedia* getComponentInspectionMultimedia(long id) throws ServerError;

    /**
     * Gets a list of all ComponentInspectionMultimedia object IDs.
     *
     * @return list of ComponentInspectionMultimedia object IDs
     */
    idempotent IdList getComponentInspectionMultimediaIds() throws ServerError;

    /**
     * Gets a list of ComponentInspectionMultimedia object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of ComponentInspectionMultimedia object IDs
     * @return list of ComponentInspectionMultimedia object proxies
     */
    idempotent ComponentInspectionMultimediaList getComponentInspectionMultimediaList(IdList ids) throws ServerError;

    /**
     * Gets the ComponentInspectionMultimedia object fields.
     *
     * @param id ComponentInspectionMultimedia object ID
     * @return ComponentInspectionMultimedia object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent ComponentInspectionMultimediaFields getComponentInspectionMultimediaFields(long id) throws ServerError;

    /**
     * Gets a list of ComponentInspectionMultimedia object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of ComponentInspectionMultimedia object IDs
     * @return list of ComponentInspectionMultimedia object fields
     */
    idempotent ComponentInspectionMultimediaFieldsList getComponentInspectionMultimediaFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all ComponentInspectionMultimedia objects matching the given
     * reference fields.
     *
     * @param fields ComponentInspectionMultimedia object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching ComponentInspectionMultimedia objects
     */
    idempotent IdList findEqualComponentInspectionMultimedia(ComponentInspectionMultimediaFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named ComponentInspectionMultimedia object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields ComponentInspectionMultimedia object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setComponentInspectionMultimediaFields(ComponentInspectionMultimediaFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named ComponentInspectionMultimedia object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setComponentInspectionMultimediaFieldsList(ComponentInspectionMultimediaFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a ElementInspectionMultimedia object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addElementInspectionMultimedia(ElementInspectionMultimediaFields fields) throws ServerError;

    /**
     * Adds a set of ElementInspectionMultimedia objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addElementInspectionMultimediaList(ElementInspectionMultimediaFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified ElementInspectionMultimedia object.
     *
     * @param id  ElementInspectionMultimedia object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delElementInspectionMultimedia(long id) throws ServerError;

    /**
     * Gets the ElementInspectionMultimedia object proxy.
     *
     * @param id  ElementInspectionMultimedia object ID
     * @return ElementInspectionMultimedia object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent ElementInspectionMultimedia* getElementInspectionMultimedia(long id) throws ServerError;

    /**
     * Gets a list of all ElementInspectionMultimedia object IDs.
     *
     * @return list of ElementInspectionMultimedia object IDs
     */
    idempotent IdList getElementInspectionMultimediaIds() throws ServerError;

    /**
     * Gets a list of ElementInspectionMultimedia object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of ElementInspectionMultimedia object IDs
     * @return list of ElementInspectionMultimedia object proxies
     */
    idempotent ElementInspectionMultimediaList getElementInspectionMultimediaList(IdList ids) throws ServerError;

    /**
     * Gets the ElementInspectionMultimedia object fields.
     *
     * @param id ElementInspectionMultimedia object ID
     * @return ElementInspectionMultimedia object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent ElementInspectionMultimediaFields getElementInspectionMultimediaFields(long id) throws ServerError;

    /**
     * Gets a list of ElementInspectionMultimedia object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of ElementInspectionMultimedia object IDs
     * @return list of ElementInspectionMultimedia object fields
     */
    idempotent ElementInspectionMultimediaFieldsList getElementInspectionMultimediaFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all ElementInspectionMultimedia objects matching the given
     * reference fields.
     *
     * @param fields ElementInspectionMultimedia object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching ElementInspectionMultimedia objects
     */
    idempotent IdList findEqualElementInspectionMultimedia(ElementInspectionMultimediaFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named ElementInspectionMultimedia object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields ElementInspectionMultimedia object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setElementInspectionMultimediaFields(ElementInspectionMultimediaFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named ElementInspectionMultimedia object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setElementInspectionMultimediaFieldsList(ElementInspectionMultimediaFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a InspectionObservation object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addInspectionObservation(InspectionObservationFields fields) throws ServerError;

    /**
     * Adds a set of InspectionObservation objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addInspectionObservationList(InspectionObservationFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified InspectionObservation object.
     *
     * @param id  InspectionObservation object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delInspectionObservation(long id) throws ServerError;

    /**
     * Gets the InspectionObservation object proxy.
     *
     * @param id  InspectionObservation object ID
     * @return InspectionObservation object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent InspectionObservation* getInspectionObservation(long id) throws ServerError;

    /**
     * Gets a list of all InspectionObservation object IDs.
     *
     * @return list of InspectionObservation object IDs
     */
    idempotent IdList getInspectionObservationIds() throws ServerError;

    /**
     * Gets a list of InspectionObservation object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of InspectionObservation object IDs
     * @return list of InspectionObservation object proxies
     */
    idempotent InspectionObservationList getInspectionObservationList(IdList ids) throws ServerError;

    /**
     * Gets the InspectionObservation object fields.
     *
     * @param id InspectionObservation object ID
     * @return InspectionObservation object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent InspectionObservationFields getInspectionObservationFields(long id) throws ServerError;

    /**
     * Gets a list of InspectionObservation object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of InspectionObservation object IDs
     * @return list of InspectionObservation object fields
     */
    idempotent InspectionObservationFieldsList getInspectionObservationFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all InspectionObservation objects matching the given
     * reference fields.
     *
     * @param fields InspectionObservation object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching InspectionObservation objects
     */
    idempotent IdList findEqualInspectionObservation(InspectionObservationFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named InspectionObservation object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields InspectionObservation object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setInspectionObservationFields(InspectionObservationFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named InspectionObservation object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setInspectionObservationFieldsList(InspectionObservationFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a InspectionMultimediaTags object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addInspectionMultimediaTags(InspectionMultimediaTagsFields fields) throws ServerError;

    /**
     * Adds a set of InspectionMultimediaTags objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addInspectionMultimediaTagsList(InspectionMultimediaTagsFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified InspectionMultimediaTags object.
     *
     * @param id  InspectionMultimediaTags object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delInspectionMultimediaTags(long id) throws ServerError;

    /**
     * Gets the InspectionMultimediaTags object proxy.
     *
     * @param id  InspectionMultimediaTags object ID
     * @return InspectionMultimediaTags object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent InspectionMultimediaTags* getInspectionMultimediaTags(long id) throws ServerError;

    /**
     * Gets a list of all InspectionMultimediaTags object IDs.
     *
     * @return list of InspectionMultimediaTags object IDs
     */
    idempotent IdList getInspectionMultimediaTagsIds() throws ServerError;

    /**
     * Gets a list of InspectionMultimediaTags object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of InspectionMultimediaTags object IDs
     * @return list of InspectionMultimediaTags object proxies
     */
    idempotent InspectionMultimediaTagsList getInspectionMultimediaTagsList(IdList ids) throws ServerError;

    /**
     * Gets the InspectionMultimediaTags object fields.
     *
     * @param id InspectionMultimediaTags object ID
     * @return InspectionMultimediaTags object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent InspectionMultimediaTagsFields getInspectionMultimediaTagsFields(long id) throws ServerError;

    /**
     * Gets a list of InspectionMultimediaTags object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of InspectionMultimediaTags object IDs
     * @return list of InspectionMultimediaTags object fields
     */
    idempotent InspectionMultimediaTagsFieldsList getInspectionMultimediaTagsFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all InspectionMultimediaTags objects matching the given
     * reference fields.
     *
     * @param fields InspectionMultimediaTags object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching InspectionMultimediaTags objects
     */
    idempotent IdList findEqualInspectionMultimediaTags(InspectionMultimediaTagsFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named InspectionMultimediaTags object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields InspectionMultimediaTags object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setInspectionMultimediaTagsFields(InspectionMultimediaTagsFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named InspectionMultimediaTags object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setInspectionMultimediaTagsFieldsList(InspectionMultimediaTagsFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a StructureComponentPoint object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addStructureComponentPoint(StructureComponentPointFields fields) throws ServerError;

    /**
     * Adds a set of StructureComponentPoint objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addStructureComponentPointList(StructureComponentPointFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified StructureComponentPoint object.
     *
     * @param id  StructureComponentPoint object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delStructureComponentPoint(long id) throws ServerError;

    /**
     * Gets the StructureComponentPoint object proxy.
     *
     * @param id  StructureComponentPoint object ID
     * @return StructureComponentPoint object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent StructureComponentPoint* getStructureComponentPoint(long id) throws ServerError;

    /**
     * Gets a list of all StructureComponentPoint object IDs.
     *
     * @return list of StructureComponentPoint object IDs
     */
    idempotent IdList getStructureComponentPointIds() throws ServerError;

    /**
     * Gets a list of StructureComponentPoint object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of StructureComponentPoint object IDs
     * @return list of StructureComponentPoint object proxies
     */
    idempotent StructureComponentPointList getStructureComponentPointList(IdList ids) throws ServerError;

    /**
     * Gets the StructureComponentPoint object fields.
     *
     * @param id StructureComponentPoint object ID
     * @return StructureComponentPoint object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent StructureComponentPointFields getStructureComponentPointFields(long id) throws ServerError;

    /**
     * Gets a list of StructureComponentPoint object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of StructureComponentPoint object IDs
     * @return list of StructureComponentPoint object fields
     */
    idempotent StructureComponentPointFieldsList getStructureComponentPointFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all StructureComponentPoint objects matching the given
     * reference fields.
     *
     * @param fields StructureComponentPoint object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching StructureComponentPoint objects
     */
    idempotent IdList findEqualStructureComponentPoint(StructureComponentPointFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named StructureComponentPoint object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields StructureComponentPoint object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setStructureComponentPointFields(StructureComponentPointFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named StructureComponentPoint object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setStructureComponentPointFieldsList(StructureComponentPointFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a StructureComponentCADModel object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addStructureComponentCADModel(StructureComponentCADModelFields fields) throws ServerError;

    /**
     * Adds a set of StructureComponentCADModel objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addStructureComponentCADModelList(StructureComponentCADModelFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified StructureComponentCADModel object.
     *
     * @param id  StructureComponentCADModel object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delStructureComponentCADModel(long id) throws ServerError;

    /**
     * Gets the StructureComponentCADModel object proxy.
     *
     * @param id  StructureComponentCADModel object ID
     * @return StructureComponentCADModel object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent StructureComponentCADModel* getStructureComponentCADModel(long id) throws ServerError;

    /**
     * Gets a list of all StructureComponentCADModel object IDs.
     *
     * @return list of StructureComponentCADModel object IDs
     */
    idempotent IdList getStructureComponentCADModelIds() throws ServerError;

    /**
     * Gets a list of StructureComponentCADModel object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of StructureComponentCADModel object IDs
     * @return list of StructureComponentCADModel object proxies
     */
    idempotent StructureComponentCADModelList getStructureComponentCADModelList(IdList ids) throws ServerError;

    /**
     * Gets the StructureComponentCADModel object fields.
     *
     * @param id StructureComponentCADModel object ID
     * @return StructureComponentCADModel object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent StructureComponentCADModelFields getStructureComponentCADModelFields(long id) throws ServerError;

    /**
     * Gets a list of StructureComponentCADModel object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of StructureComponentCADModel object IDs
     * @return list of StructureComponentCADModel object fields
     */
    idempotent StructureComponentCADModelFieldsList getStructureComponentCADModelFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all StructureComponentCADModel objects matching the given
     * reference fields.
     *
     * @param fields StructureComponentCADModel object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching StructureComponentCADModel objects
     */
    idempotent IdList findEqualStructureComponentCADModel(StructureComponentCADModelFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named StructureComponentCADModel object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields StructureComponentCADModel object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setStructureComponentCADModelFields(StructureComponentCADModelFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named StructureComponentCADModel object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setStructureComponentCADModelFieldsList(StructureComponentCADModelFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a CompRepairFinalCond object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addCompRepairFinalCond(CompRepairFinalCondFields fields) throws ServerError;

    /**
     * Adds a set of CompRepairFinalCond objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addCompRepairFinalCondList(CompRepairFinalCondFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified CompRepairFinalCond object.
     *
     * @param id  CompRepairFinalCond object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delCompRepairFinalCond(long id) throws ServerError;

    /**
     * Gets the CompRepairFinalCond object proxy.
     *
     * @param id  CompRepairFinalCond object ID
     * @return CompRepairFinalCond object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent CompRepairFinalCond* getCompRepairFinalCond(long id) throws ServerError;

    /**
     * Gets a list of all CompRepairFinalCond object IDs.
     *
     * @return list of CompRepairFinalCond object IDs
     */
    idempotent IdList getCompRepairFinalCondIds() throws ServerError;

    /**
     * Gets a list of CompRepairFinalCond object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of CompRepairFinalCond object IDs
     * @return list of CompRepairFinalCond object proxies
     */
    idempotent CompRepairFinalCondList getCompRepairFinalCondList(IdList ids) throws ServerError;

    /**
     * Gets the CompRepairFinalCond object fields.
     *
     * @param id CompRepairFinalCond object ID
     * @return CompRepairFinalCond object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent CompRepairFinalCondFields getCompRepairFinalCondFields(long id) throws ServerError;

    /**
     * Gets a list of CompRepairFinalCond object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of CompRepairFinalCond object IDs
     * @return list of CompRepairFinalCond object fields
     */
    idempotent CompRepairFinalCondFieldsList getCompRepairFinalCondFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all CompRepairFinalCond objects matching the given
     * reference fields.
     *
     * @param fields CompRepairFinalCond object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching CompRepairFinalCond objects
     */
    idempotent IdList findEqualCompRepairFinalCond(CompRepairFinalCondFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named CompRepairFinalCond object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields CompRepairFinalCond object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setCompRepairFinalCondFields(CompRepairFinalCondFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named CompRepairFinalCond object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setCompRepairFinalCondFieldsList(CompRepairFinalCondFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a CompRepairTimelineMatrix object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addCompRepairTimelineMatrix(CompRepairTimelineMatrixFields fields) throws ServerError;

    /**
     * Adds a set of CompRepairTimelineMatrix objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addCompRepairTimelineMatrixList(CompRepairTimelineMatrixFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified CompRepairTimelineMatrix object.
     *
     * @param id  CompRepairTimelineMatrix object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delCompRepairTimelineMatrix(long id) throws ServerError;

    /**
     * Gets the CompRepairTimelineMatrix object proxy.
     *
     * @param id  CompRepairTimelineMatrix object ID
     * @return CompRepairTimelineMatrix object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent CompRepairTimelineMatrix* getCompRepairTimelineMatrix(long id) throws ServerError;

    /**
     * Gets a list of all CompRepairTimelineMatrix object IDs.
     *
     * @return list of CompRepairTimelineMatrix object IDs
     */
    idempotent IdList getCompRepairTimelineMatrixIds() throws ServerError;

    /**
     * Gets a list of CompRepairTimelineMatrix object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of CompRepairTimelineMatrix object IDs
     * @return list of CompRepairTimelineMatrix object proxies
     */
    idempotent CompRepairTimelineMatrixList getCompRepairTimelineMatrixList(IdList ids) throws ServerError;

    /**
     * Gets the CompRepairTimelineMatrix object fields.
     *
     * @param id CompRepairTimelineMatrix object ID
     * @return CompRepairTimelineMatrix object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent CompRepairTimelineMatrixFields getCompRepairTimelineMatrixFields(long id) throws ServerError;

    /**
     * Gets a list of CompRepairTimelineMatrix object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of CompRepairTimelineMatrix object IDs
     * @return list of CompRepairTimelineMatrix object fields
     */
    idempotent CompRepairTimelineMatrixFieldsList getCompRepairTimelineMatrixFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all CompRepairTimelineMatrix objects matching the given
     * reference fields.
     *
     * @param fields CompRepairTimelineMatrix object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching CompRepairTimelineMatrix objects
     */
    idempotent IdList findEqualCompRepairTimelineMatrix(CompRepairTimelineMatrixFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named CompRepairTimelineMatrix object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields CompRepairTimelineMatrix object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setCompRepairTimelineMatrixFields(CompRepairTimelineMatrixFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named CompRepairTimelineMatrix object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setCompRepairTimelineMatrixFieldsList(CompRepairTimelineMatrixFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a CompEnvBurdenMatrix object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addCompEnvBurdenMatrix(CompEnvBurdenMatrixFields fields) throws ServerError;

    /**
     * Adds a set of CompEnvBurdenMatrix objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addCompEnvBurdenMatrixList(CompEnvBurdenMatrixFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified CompEnvBurdenMatrix object.
     *
     * @param id  CompEnvBurdenMatrix object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delCompEnvBurdenMatrix(long id) throws ServerError;

    /**
     * Gets the CompEnvBurdenMatrix object proxy.
     *
     * @param id  CompEnvBurdenMatrix object ID
     * @return CompEnvBurdenMatrix object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent CompEnvBurdenMatrix* getCompEnvBurdenMatrix(long id) throws ServerError;

    /**
     * Gets a list of all CompEnvBurdenMatrix object IDs.
     *
     * @return list of CompEnvBurdenMatrix object IDs
     */
    idempotent IdList getCompEnvBurdenMatrixIds() throws ServerError;

    /**
     * Gets a list of CompEnvBurdenMatrix object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of CompEnvBurdenMatrix object IDs
     * @return list of CompEnvBurdenMatrix object proxies
     */
    idempotent CompEnvBurdenMatrixList getCompEnvBurdenMatrixList(IdList ids) throws ServerError;

    /**
     * Gets the CompEnvBurdenMatrix object fields.
     *
     * @param id CompEnvBurdenMatrix object ID
     * @return CompEnvBurdenMatrix object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent CompEnvBurdenMatrixFields getCompEnvBurdenMatrixFields(long id) throws ServerError;

    /**
     * Gets a list of CompEnvBurdenMatrix object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of CompEnvBurdenMatrix object IDs
     * @return list of CompEnvBurdenMatrix object fields
     */
    idempotent CompEnvBurdenMatrixFieldsList getCompEnvBurdenMatrixFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all CompEnvBurdenMatrix objects matching the given
     * reference fields.
     *
     * @param fields CompEnvBurdenMatrix object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching CompEnvBurdenMatrix objects
     */
    idempotent IdList findEqualCompEnvBurdenMatrix(CompEnvBurdenMatrixFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named CompEnvBurdenMatrix object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields CompEnvBurdenMatrix object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setCompEnvBurdenMatrixFields(CompEnvBurdenMatrixFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named CompEnvBurdenMatrix object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setCompEnvBurdenMatrixFieldsList(CompEnvBurdenMatrixFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a WeighInMotionStation object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addWeighInMotionStation(WeighInMotionStationFields fields) throws ServerError;

    /**
     * Adds a set of WeighInMotionStation objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addWeighInMotionStationList(WeighInMotionStationFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified WeighInMotionStation object.
     *
     * @param id  WeighInMotionStation object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delWeighInMotionStation(long id) throws ServerError;

    /**
     * Gets the WeighInMotionStation object proxy.
     *
     * @param id  WeighInMotionStation object ID
     * @return WeighInMotionStation object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent WeighInMotionStation* getWeighInMotionStation(long id) throws ServerError;

    /**
     * Gets a list of all WeighInMotionStation object IDs.
     *
     * @return list of WeighInMotionStation object IDs
     */
    idempotent IdList getWeighInMotionStationIds() throws ServerError;

    /**
     * Gets a list of WeighInMotionStation object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of WeighInMotionStation object IDs
     * @return list of WeighInMotionStation object proxies
     */
    idempotent WeighInMotionStationList getWeighInMotionStationList(IdList ids) throws ServerError;

    /**
     * Gets the WeighInMotionStation object fields.
     *
     * @param id WeighInMotionStation object ID
     * @return WeighInMotionStation object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent WeighInMotionStationFields getWeighInMotionStationFields(long id) throws ServerError;

    /**
     * Gets a list of WeighInMotionStation object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of WeighInMotionStation object IDs
     * @return list of WeighInMotionStation object fields
     */
    idempotent WeighInMotionStationFieldsList getWeighInMotionStationFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all WeighInMotionStation objects matching the given
     * reference fields.
     *
     * @param fields WeighInMotionStation object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching WeighInMotionStation objects
     */
    idempotent IdList findEqualWeighInMotionStation(WeighInMotionStationFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named WeighInMotionStation object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields WeighInMotionStation object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setWeighInMotionStationFields(WeighInMotionStationFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named WeighInMotionStation object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setWeighInMotionStationFieldsList(WeighInMotionStationFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a WeighInMotionSensorData object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addWeighInMotionSensorData(WeighInMotionSensorDataFields fields) throws ServerError;

    /**
     * Adds a set of WeighInMotionSensorData objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addWeighInMotionSensorDataList(WeighInMotionSensorDataFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified WeighInMotionSensorData object.
     *
     * @param id  WeighInMotionSensorData object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delWeighInMotionSensorData(long id) throws ServerError;

    /**
     * Gets the WeighInMotionSensorData object proxy.
     *
     * @param id  WeighInMotionSensorData object ID
     * @return WeighInMotionSensorData object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent WeighInMotionSensorData* getWeighInMotionSensorData(long id) throws ServerError;

    /**
     * Gets a list of all WeighInMotionSensorData object IDs.
     *
     * @return list of WeighInMotionSensorData object IDs
     */
    idempotent IdList getWeighInMotionSensorDataIds() throws ServerError;

    /**
     * Gets a list of WeighInMotionSensorData object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of WeighInMotionSensorData object IDs
     * @return list of WeighInMotionSensorData object proxies
     */
    idempotent WeighInMotionSensorDataList getWeighInMotionSensorDataList(IdList ids) throws ServerError;

    /**
     * Gets the WeighInMotionSensorData object fields.
     *
     * @param id WeighInMotionSensorData object ID
     * @return WeighInMotionSensorData object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent WeighInMotionSensorDataFields getWeighInMotionSensorDataFields(long id) throws ServerError;

    /**
     * Gets a list of WeighInMotionSensorData object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of WeighInMotionSensorData object IDs
     * @return list of WeighInMotionSensorData object fields
     */
    idempotent WeighInMotionSensorDataFieldsList getWeighInMotionSensorDataFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all WeighInMotionSensorData objects matching the given
     * reference fields.
     *
     * @param fields WeighInMotionSensorData object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching WeighInMotionSensorData objects
     */
    idempotent IdList findEqualWeighInMotionSensorData(WeighInMotionSensorDataFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named WeighInMotionSensorData object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields WeighInMotionSensorData object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setWeighInMotionSensorDataFields(WeighInMotionSensorDataFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named WeighInMotionSensorData object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setWeighInMotionSensorDataFieldsList(WeighInMotionSensorDataFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a MappingMatrix object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addMappingMatrix(MappingMatrixFields fields) throws ServerError;

    /**
     * Adds a set of MappingMatrix objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addMappingMatrixList(MappingMatrixFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified MappingMatrix object.
     *
     * @param id  MappingMatrix object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delMappingMatrix(long id) throws ServerError;

    /**
     * Gets the MappingMatrix object proxy.
     *
     * @param id  MappingMatrix object ID
     * @return MappingMatrix object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent MappingMatrix* getMappingMatrix(long id) throws ServerError;

    /**
     * Gets a list of all MappingMatrix object IDs.
     *
     * @return list of MappingMatrix object IDs
     */
    idempotent IdList getMappingMatrixIds() throws ServerError;

    /**
     * Gets a list of MappingMatrix object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of MappingMatrix object IDs
     * @return list of MappingMatrix object proxies
     */
    idempotent MappingMatrixList getMappingMatrixList(IdList ids) throws ServerError;

    /**
     * Gets the MappingMatrix object fields.
     *
     * @param id MappingMatrix object ID
     * @return MappingMatrix object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent MappingMatrixFields getMappingMatrixFields(long id) throws ServerError;

    /**
     * Gets a list of MappingMatrix object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of MappingMatrix object IDs
     * @return list of MappingMatrix object fields
     */
    idempotent MappingMatrixFieldsList getMappingMatrixFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all MappingMatrix objects matching the given
     * reference fields.
     *
     * @param fields MappingMatrix object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching MappingMatrix objects
     */
    idempotent IdList findEqualMappingMatrix(MappingMatrixFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named MappingMatrix object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields MappingMatrix object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setMappingMatrixFields(MappingMatrixFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named MappingMatrix object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setMappingMatrixFieldsList(MappingMatrixFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a MeasurementCycle object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addMeasurementCycle(MeasurementCycleFields fields) throws ServerError;

    /**
     * Adds a set of MeasurementCycle objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addMeasurementCycleList(MeasurementCycleFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified MeasurementCycle object.
     *
     * @param id  MeasurementCycle object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delMeasurementCycle(long id) throws ServerError;

    /**
     * Gets the MeasurementCycle object proxy.
     *
     * @param id  MeasurementCycle object ID
     * @return MeasurementCycle object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent MeasurementCycle* getMeasurementCycle(long id) throws ServerError;

    /**
     * Gets a list of all MeasurementCycle object IDs.
     *
     * @return list of MeasurementCycle object IDs
     */
    idempotent IdList getMeasurementCycleIds() throws ServerError;

    /**
     * Gets a list of MeasurementCycle object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of MeasurementCycle object IDs
     * @return list of MeasurementCycle object proxies
     */
    idempotent MeasurementCycleList getMeasurementCycleList(IdList ids) throws ServerError;

    /**
     * Gets the MeasurementCycle object fields.
     *
     * @param id MeasurementCycle object ID
     * @return MeasurementCycle object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent MeasurementCycleFields getMeasurementCycleFields(long id) throws ServerError;

    /**
     * Gets a list of MeasurementCycle object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of MeasurementCycle object IDs
     * @return list of MeasurementCycle object fields
     */
    idempotent MeasurementCycleFieldsList getMeasurementCycleFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all MeasurementCycle objects matching the given
     * reference fields.
     *
     * @param fields MeasurementCycle object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching MeasurementCycle objects
     */
    idempotent IdList findEqualMeasurementCycle(MeasurementCycleFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named MeasurementCycle object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields MeasurementCycle object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setMeasurementCycleFields(MeasurementCycleFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named MeasurementCycle object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setMeasurementCycleFieldsList(MeasurementCycleFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a StaticLoadToSensorMapping object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addStaticLoadToSensorMapping(StaticLoadToSensorMappingFields fields) throws ServerError;

    /**
     * Adds a set of StaticLoadToSensorMapping objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addStaticLoadToSensorMappingList(StaticLoadToSensorMappingFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified StaticLoadToSensorMapping object.
     *
     * @param id  StaticLoadToSensorMapping object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delStaticLoadToSensorMapping(long id) throws ServerError;

    /**
     * Gets the StaticLoadToSensorMapping object proxy.
     *
     * @param id  StaticLoadToSensorMapping object ID
     * @return StaticLoadToSensorMapping object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent StaticLoadToSensorMapping* getStaticLoadToSensorMapping(long id) throws ServerError;

    /**
     * Gets a list of all StaticLoadToSensorMapping object IDs.
     *
     * @return list of StaticLoadToSensorMapping object IDs
     */
    idempotent IdList getStaticLoadToSensorMappingIds() throws ServerError;

    /**
     * Gets a list of StaticLoadToSensorMapping object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of StaticLoadToSensorMapping object IDs
     * @return list of StaticLoadToSensorMapping object proxies
     */
    idempotent StaticLoadToSensorMappingList getStaticLoadToSensorMappingList(IdList ids) throws ServerError;

    /**
     * Gets the StaticLoadToSensorMapping object fields.
     *
     * @param id StaticLoadToSensorMapping object ID
     * @return StaticLoadToSensorMapping object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent StaticLoadToSensorMappingFields getStaticLoadToSensorMappingFields(long id) throws ServerError;

    /**
     * Gets a list of StaticLoadToSensorMapping object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of StaticLoadToSensorMapping object IDs
     * @return list of StaticLoadToSensorMapping object fields
     */
    idempotent StaticLoadToSensorMappingFieldsList getStaticLoadToSensorMappingFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all StaticLoadToSensorMapping objects matching the given
     * reference fields.
     *
     * @param fields StaticLoadToSensorMapping object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching StaticLoadToSensorMapping objects
     */
    idempotent IdList findEqualStaticLoadToSensorMapping(StaticLoadToSensorMappingFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named StaticLoadToSensorMapping object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields StaticLoadToSensorMapping object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setStaticLoadToSensorMappingFields(StaticLoadToSensorMappingFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named StaticLoadToSensorMapping object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setStaticLoadToSensorMappingFieldsList(StaticLoadToSensorMappingFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a DaqUnitChannelData object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addDaqUnitChannelData(DaqUnitChannelDataFields fields) throws ServerError;

    /**
     * Adds a set of DaqUnitChannelData objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addDaqUnitChannelDataList(DaqUnitChannelDataFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified DaqUnitChannelData object.
     *
     * @param id  DaqUnitChannelData object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delDaqUnitChannelData(long id) throws ServerError;

    /**
     * Gets the DaqUnitChannelData object proxy.
     *
     * @param id  DaqUnitChannelData object ID
     * @return DaqUnitChannelData object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent DaqUnitChannelData* getDaqUnitChannelData(long id) throws ServerError;

    /**
     * Gets a list of all DaqUnitChannelData object IDs.
     *
     * @return list of DaqUnitChannelData object IDs
     */
    idempotent IdList getDaqUnitChannelDataIds() throws ServerError;

    /**
     * Gets a list of DaqUnitChannelData object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of DaqUnitChannelData object IDs
     * @return list of DaqUnitChannelData object proxies
     */
    idempotent DaqUnitChannelDataList getDaqUnitChannelDataList(IdList ids) throws ServerError;

    /**
     * Gets the DaqUnitChannelData object fields.
     *
     * @param id DaqUnitChannelData object ID
     * @return DaqUnitChannelData object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent DaqUnitChannelDataFields getDaqUnitChannelDataFields(long id) throws ServerError;

    /**
     * Gets a list of DaqUnitChannelData object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of DaqUnitChannelData object IDs
     * @return list of DaqUnitChannelData object fields
     */
    idempotent DaqUnitChannelDataFieldsList getDaqUnitChannelDataFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all DaqUnitChannelData objects matching the given
     * reference fields.
     *
     * @param fields DaqUnitChannelData object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching DaqUnitChannelData objects
     */
    idempotent IdList findEqualDaqUnitChannelData(DaqUnitChannelDataFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named DaqUnitChannelData object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields DaqUnitChannelData object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setDaqUnitChannelDataFields(DaqUnitChannelDataFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named DaqUnitChannelData object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setDaqUnitChannelDataFieldsList(DaqUnitChannelDataFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Adds a SensorChannelData object to the store.
     *
     * @param fields object fields
     * @return newly assigned ID
     */
    long addSensorChannelData(SensorChannelDataFields fields) throws ServerError;

    /**
     * Adds a set of SensorChannelData objects to the store.
     *
     * @param fieldsList list of object fields
     * @return list of newly assigned IDs
     */
    IdList addSensorChannelDataList(SensorChannelDataFieldsList fieldsList) throws ServerError;

    /**
     * Deletes the identified SensorChannelData object.
     *
     * @param id  SensorChannelData object ID
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    void delSensorChannelData(long id) throws ServerError;

    /**
     * Gets the SensorChannelData object proxy.
     *
     * @param id  SensorChannelData object ID
     * @return SensorChannelData object proxy
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent SensorChannelData* getSensorChannelData(long id) throws ServerError;

    /**
     * Gets a list of all SensorChannelData object IDs.
     *
     * @return list of SensorChannelData object IDs
     */
    idempotent IdList getSensorChannelDataIds() throws ServerError;

    /**
     * Gets a list of SensorChannelData object proxies.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of SensorChannelData object IDs
     * @return list of SensorChannelData object proxies
     */
    idempotent SensorChannelDataList getSensorChannelDataList(IdList ids) throws ServerError;

    /**
     * Gets the SensorChannelData object fields.
     *
     * @param id SensorChannelData object ID
     * @return SensorChannelData object fields
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent SensorChannelDataFields getSensorChannelDataFields(long id) throws ServerError;

    /**
     * Gets a list of SensorChannelData object fields.
     *
     * Objects that do not exist are ignored, in which case the returned list does
     * not correspond one-to-one with the given ID list.
     *
     * @param ids list of SensorChannelData object IDs
     * @return list of SensorChannelData object fields
     */
    idempotent SensorChannelDataFieldsList getSensorChannelDataFieldsList(IdList ids) throws ServerError;

    /**
     * Gets a list of IDs of all SensorChannelData objects matching the given
     * reference fields.
     *
     * @param fields SensorChannelData object fields to compare to
     * @param fieldNames list of names of fields to compare (empty is all)
     * @return list of IDs of matching SensorChannelData objects
     */
    idempotent IdList findEqualSensorChannelData(SensorChannelDataFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named SensorChannelData object fields.
     *
     * The 'fields' variable must have a valid id field. 
     *
     * @param fields SensorChannelData object fields 
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setSensorChannelDataFields(SensorChannelDataFields fields,
        FieldNameList fieldNames) throws ServerError;

    /**
     * Updates the named SensorChannelData object fields of a list of objects.
     *
     * The 'fields' variables must have a valid id field. 
     *
     * @param fieldsList list of object fields
     * @param fieldNames list of names of fields to update (empty is all)
     * @throws ObjectDoesNotExistError if the object with the given ID does not exist
     */
    idempotent void setSensorChannelDataFieldsList(SensorChannelDataFieldsList fieldsList,
        FieldNameList fieldNames) throws ServerError;
  };
  
  /**
   * Session interface.
   *
   * @see SessionFactory
   */
  interface Session {
    /**
     * Gets the SenStore manager.
     * @return [SenStoreMngr] proxy
     */
    SenStoreMngr* getManager();
    /**
     * Gets the name of this session.
     *
     * @return session name
     */
    idempotent string getName();
    /**
     * Gets the session time-out setting.
     *
     * @return session time-out [s]
     * @see refresh()
     */
    idempotent float getTimeout();
    /**
     * Destroys this session.
     *
     * Call this method when the session is finished, for a speedy release
     * of resources on the server.
     */
    void destroy();
    /**
     * Refreshes this session, resetting the time-out counter on the server.
     *
     * This session must be refreshed at an interval shorter than the
     * time-out value to stay alive.  Otherwise the server may destroy
     * the session, and the session will no longer be valid.
     */
    idempotent void refresh();
  };
  
  /**
   * Exclusive session interface.
   *
   * This interface is used to guarantee exclusive access to the database,
   * for example for backup, and import/export.
   *
   * @see Session
   * @see SessionFactory
   */
  interface SessionExclusive extends Session {
    /**
     * Prepares the database for backup.
     *
     * Currently this only releases the HDF5 file, so it can be copied.
     */
    void enterBackup();
    /**
     * Prepares the database for normal use.
     *
     * Currently just only reopens the HDF5 file.
     */
    void exitBackup();
  };

  /**
   * Session factory singleton.
   *
   * Use this interface to create a session, needed to interface with the
   * SenStore database.
   */
  interface SessionFactory {
    /**
     * Creates a normal session, allowing access by multiple clients.
     *
     * @param name session name
     * @return [Session] proxy
     */
    Session* createSession(string name);
    /**
     * Creates an exclusive-access session, blocking access by
     * other clients.
     *
     * @param name session name
     * @return [SessionExclusive] proxy
     */
    SessionExclusive* createSessionExclusive(string name);
  };
};
