// Just dumping all mock data here for now
// @todo use factories and browserify for require rather then tacking onto window

window.MOCKS = {};

window.MOCKS.initiatives = [
  {
    "id": "7",
    "attributes": {
      "name": "Mobilising Playford's Assets",
      "description": ""
    }
  },
  {
    "id": "16",
    "attributes": {
      "name": "Creating a new one to delete",
      "description": "asdgasdg"
    }
  }
];

window.MOCKS.dataModel = [
  // Groups
  {
    "id": "1",
    "type": "focus_area_groups",
    "attributes": {
      "name": "Planned Exploitation of Community Knowledge, Ideas and Innovations",
      "description": null
    },
    "relationships": {
      "focusAreas": {
        "data": [
          {
            "type": "focus_areas",
            "id": "8"
          }
        ]
      }
    }
  },
  {
    "id": "2",
    "type": "focus_area_groups",
    "attributes": {
      "name": "Building Adaptive Capacity of Communities",
      "description": ""
    },
    "relationships": {
      "focusAreas": {
        "data": [
          {
            "type": "focus_areas",
            "id": "21"
          }
        ]
      }
    }
  },
  // Areas
  {
    "id": "8",
    "type": "focus_areas",
    "attributes": {
      "name": "Community – government bureaucracy interface",
      "description": ""
    },
    "relationships": {
      "focusAreaGroup": {
        "data": {
          "type": "focus_area_groups",
          "id": "1"
        }
      }
    }
  },
  {
    "id": "21",
    "type": "focus_areas",
    "attributes": {
      "name": "Create a disequilibrium state",
      "description": ""
    },
    "relationships": {
      "focusAreaGroup": {
        "data": {
          "type": "focus_area_groups",
          "id": "2"
        }
      }
    }
  },
  {
    "id": "1",
    "type": "focus_areas",
    "attributes": {
      "name": "Create a disequilibrium state",
      "description": ""
    },
    "relationships": {
      "focusAreaGroup": {
        "data": {
          "type": "focus_area_groups",
          "id": "1"
        }
      }
    }
  },
  // Chars
  {
    "id": "34",
    "type": "characteristics",
    "attributes": {
      "name": "Gather, retain and reuse community knowledge and ideas in other contexts"
    },
    "relationships": {
      "focusArea": {
        "data": {
          "type": "focus_areas",
          "id": "8"
        }
      }
    }
  },
  {
    "id": "3",
    "type": "characteristics",
    "attributes": {
      "name": "Manage initial starting conditions"
    },
    "relationships": {
      "focusArea": {
        "data": {
          "type": "focus_areas",
          "id": "1"
        }
      }
    }
  },
  {
    "id": "4",
    "type": "characteristics",
    "attributes": {
      "name": "Specify goals in advance"
    },
    "relationships": {
      "focusArea": {
        "data": {
          "type": "focus_areas",
          "id": "1"
        }
      }
    }
  },
  {
    "id": "5",
    "type": "characteristics",
    "attributes": {
      "name": "Establish appropriate boundaries"
    },
    "relationships": {
      "focusArea": {
        "data": {
          "type": "focus_areas",
          "id": "21"
        }
      }
    }
  },
  {
    "id": "6",
    "type": "characteristics",
    "attributes": {
      "name": "Embrace uncertainty"
    },
    "relationships": {
      "focusArea": {
        "data": {
          "type": "focus_areas",
          "id": "21"
        }
      }
    }
  }
];

window.MOCKS.checklist = [
  {
    "id": "246",
    "attributes": {
      "checked": true,
      "comment": "foobar"
    },
    "type": "checklist_items",
    "relationships": {
      "characteristic": {
        "data": {
          "id": "34"
        }
      },
      "initiative": {
        "data": {
          "id": "16"
        }
      }
    }
  },
  {
    "id": "55",
    "attributes": {
      "checked": null,
      "comment": ""
    },
    "type": "checklist_items",
    "relationships": {
      "characteristic": {
        "data": {
          "id": "4"
        }
      },
      "initiative": {
        "data": {
          "id": "16"
        }
      }
    }
  },
  {
    "id": "24",
    "attributes": {
      "checked": true,
      "comment": "asdf"
    },
    "type": "checklist_items",
    "relationships": {
      "characteristic": {
        "data": {
          "id": "3"
        }
      },
      "initiative": {
        "data": {
          "id": "16"
        }
      }
    }
  },
  {
    "id": "5775",
    "attributes": {
      "checked": null,
      "comment": ""
    },
    "type": "checklist_items",
    "relationships": {
      "characteristic": {
        "data": {
          "id": "5"
        }
      },
      "initiative": {
        "data": {
          "id": "16"
        }
      }
    }
  },
  {
    "id": "57735",
    "attributes": {
      "checked": true,
      "comment": "bazqux"
    },
    "type": "checklist_items",
    "relationships": {
      "characteristic": {
        "data": {
          "id": "6"
        }
      },
      "initiative": {
        "data": {
          "id": "16"
        }
      }
    }
  },
];
