class AddAffiliationToEditors < ActiveRecord::Migration[7.2]
  def up
    add_column :editors, :affiliation, :string, default: ""

    # Affiliations for all active (board + topic) editors.
    # Format: "Institution, City, Country"
    # Entries marked [VERIFY] should be confirmed before production deploy.
    affiliations = {
      # ── Board editors ────────────────────────────────────────────────────────
      "arfon"                  => "Schmidt Sciences, New York, NY, USA",
      "warrickball"            => "University of Birmingham, Birmingham, UK",
      "samhforbes"             => "Durham University, Durham, UK",
      "danielskatz"            => "University of Illinois at Urbana-Champaign, Urbana-Champaign, IL, USA",
      "rkurchin"               => "Carnegie Mellon University, Pittsburgh, PA, USA",
      "kevin-mattheus-moerman" => "University of Galway, Galway, Ireland",
      "kyleniemeyer"           => "Oregon State University, Corvallis, OR, USA",
      "kthyng"                 => "Axiom Data Science, Portland, OR, USA",
      "crvernon"               => "Pacific Northwest National Laboratory, Richland, WA, USA",

      # ── Topic editors (A) ────────────────────────────────────────────────────
      "fruzsinaagocs"          => "University of Colorado Boulder, Boulder, CO, USA",
      "galessiorob"            => "Netflix, Los Gatos, CA, USA",
      "sappelhoff"             => "Zander Labs, Berlin, Germany",
      "marlinarnz"             => "TU Berlin, Berlin, Germany",
      "jatkinson1000"          => "University of Cambridge, Cambridge, UK",

      # ── Topic editors (B) ────────────────────────────────────────────────────
      "mbarzegary"             => "Eindhoven University of Technology, Eindhoven, Netherlands",
      "likeajumprope"          => "Radboud University Medical Center, Nijmegen, Netherlands",
      "xuanxu"                 => "European Space Astronomy Centre (ESA/ESAC), Madrid, Spain",
      "phibeck"                => "TU Wien, Vienna, Austria",
      "sbenthall"              => "New York University School of Law, New York, NY, USA",
      "mbobra"                 => "State of California, Sacramento, CA, USA",
      "fboehm"                 => "University of Michigan, Ann Arbor, MI, USA",
      "boisgera"               => "Mines Paris \u2013 PSL, Paris, France",
      "borgesaugusto"          => "University of Cambridge, Cambridge, UK",
      "jborrow"                => "University of Pennsylvania, Philadelphia, PA, USA",
      "sbozzolo"               => "AWS Center for Quantum Computing, Pasadena, CA, USA",
      "jedbrown"               => "University of Colorado Boulder, Boulder, CO, USA",
      "tobibu"                 => "Heidelberg University, Heidelberg, Germany",

      # ── Topic editors (C) ────────────────────────────────────────────────────
      "philipcardiff"          => "University College Dublin, Dublin, Ireland",
      "cheginit"               => "Purdue University, West Lafayette, IN, USA",
      "piyueh"                 => "Argonne National Laboratory, Lemont, IL, USA",
      "mooniean"               => "Alan Turing Institute, London, UK",

      # ── Topic editors (D) ────────────────────────────────────────────────────
      "diehlpk"                => "Los Alamos National Laboratory, Los Alamos, NM, USA",
      "adonath"                => "Center for Astrophysics, Harvard & Smithsonian, Cambridge, MA, USA",
      "kdorheim"               => "Pacific Northwest National Laboratory, Richland, WA, USA",
      "emdupre"                => "Stanford University, Stanford, CA, USA",

      # ── Topic editors (F) ────────────────────────────────────────────────────
      "matthewfeickert"        => "University of Wisconsin-Madison, Madison, WI, USA",
      "finsberg"               => "Simula Research Laboratory, Oslo, Norway",
      "vissarion"              => "National and Kapodistrian University of Athens, Athens, Greece",

      # ── Topic editors (G) ────────────────────────────────────────────────────
      "jgaboardi"              => "Oak Ridge National Laboratory, Oak Ridge, TN, USA",
      "willgearty"             => "Syracuse University, Syracuse, NY, USA",
      "nikoleta-v3"            => "RIKEN Center for Computational Science, Kobe, Japan",
      "goldingn"               => "University of Western Australia, Perth, Australia",
      "jgostick"               => "University of Waterloo, Waterloo, Ontario, Canada",
      "haozeke"                => "University of Iceland, Reykjavik, Iceland",
      "matt-graham"            => "University College London, London, UK",
      "rekyt"                  => "Université Grenoble Alpes, Grenoble, France",

      # ── Topic editors (H) ────────────────────────────────────────────────────
      "elbeejay"               => "U.S. Department of Defense, USA",                     # [VERIFY] may be USGS
      "spholmes"               => "Stanford University, Stanford, CA, USA",

      # ── Topic editors (J) ────────────────────────────────────────────────────
      "adamrjensen"            => "Technical University of Denmark, Kgs. Lyngby, Denmark",
      "majensen"               => "Frederick National Laboratory for Cancer Research, Frederick, MD, USA",
      "prashjha"               => "South Dakota School of Mines and Technology, Rapid City, SD, USA",
      "junghans"               => "Los Alamos National Laboratory, Los Alamos, NM, USA",

      # ── Topic editors (K) ────────────────────────────────────────────────────
      "skanwal"                => "University of Melbourne, Melbourne, Australia",
      "ujjwalkarn"             => "Meta AI, Menlo Park, CA, USA",
      "drvinceknight"          => "Cardiff University, Cardiff, UK",
      "olexandr-konovalov"     => "University of St Andrews, St Andrews, UK",
      "ekourlit"               => "Argonne National Laboratory, Lemont, IL, USA",        # moved from CERN

      # ── Topic editors (L) ────────────────────────────────────────────────────
      "plaplant"               => "University of Nevada, Las Vegas, NV, USA",
      "jolars"                 => "University of Copenhagen, Copenhagen, Denmark",
      "lrnv"                   => "Aix-Marseille University, Marseille, France",
      "hugoledoux"             => "Delft University of Technology, Delft, Netherlands",
      "richardlitt"            => "Victoria University of Wellington, Wellington, New Zealand",
      "rich2355"               => "NYU Grossman School of Medicine, New York, NY, USA",

      # ── Topic editors (M) ────────────────────────────────────────────────────
      "lockwo"                 => "Extropic AI, San Francisco, CA, USA",
      "mikemahoney218"         => "U.S. Geological Survey, Boston, MA, USA",
      "samaloney"              => "Dublin Institute for Advanced Studies, Dublin, Ireland",
      "erickmartins"           => "European Molecular Biology Laboratory (EMBL), Heidelberg, Germany",
      "bmcfee"                 => "New York University, New York, NY, USA",
      "rmeli"                  => "Swiss National Supercomputing Centre (CSCS), Lugano, Switzerland",
      "srmnitc"                => "Max-Planck-Institut f\u00FCr Eisenforschung, D\u00FCsseldorf, Germany",
      "logological"            => "University of Manitoba, Winnipeg, Canada",
      "ivastar"                => "Max Planck Institute for Astronomy, Heidelberg, Germany",
      "ymzayek"                => "Aix-Marseille University, Marseille, France",          # [VERIFY] multiple roles

      # ── Topic editors (N) ────────────────────────────────────────────────────
      "kanishkan91"            => "Pacific Northwest National Laboratory, Richland, WA, USA",

      # ── Topic editors (P) ────────────────────────────────────────────────────
      "lpantano"               => "Harvard T.H. Chan School of Public Health, Boston, MA, USA",

      # ── Topic editors (R) ────────────────────────────────────────────────────
      "mahfuz05062"            => "Lowe's Home Centers, Minneapolis, MN, USA",
      "bkrayfield"             => "University of North Florida, Jacksonville, FL, USA",
      "jromanowska"            => "University of Bergen, Bergen, Norway",
      "kellyrowland"           => "Lawrence Berkeley National Laboratory, Berkeley, CA, USA",
      "nkrusch"                => "Uppsala University, Uppsala, Sweden",

      # ── Topic editors (S) ────────────────────────────────────────────────────
      "anjalisandip"           => "University of North Dakota, Grand Forks, ND, USA",
      "jbytecode"              => "Istanbul University, Istanbul, Turkey",
      "sneakers-the-rat"       => "UCLA, Los Angeles, CA, USA",
      "fabian-s"               => "Ludwig-Maximilians-Universit\u00E4t Munich, Munich, Germany",
      "observingclouds"        => "Danish Meteorological Institute, Copenhagen, Denmark",
      "adi3"                   => "Komment, Munich, Germany",
      "crsl4"                  => "University of Wisconsin-Madison, Madison, WI, USA",
      "csoneson"               => "Friedrich Miescher Institute for Biomedical Research, Basel, Switzerland",
      "espottesmith"           => "University College Dublin, Dublin, Ireland",
      "dstansby"               => "University College London, London, UK",
      "mstimberg"              => "Sorbonne Universit\u00E9, Paris, France",
      "faroit"                 => "AudioShake, Frankfurt, Germany",
      "osorensen"              => "University of Oslo, Oslo, Norway",

      # ── Topic editors (T) ────────────────────────────────────────────────────
      "fei-tao"                => "Dassault Syst\u00E8mes, West Lafayette, IN, USA",
      "gkthiruvathukal"        => "Loyola University Chicago, Chicago, IL, USA",
      "romain-thomas-shef"     => "University of Sheffield, Sheffield, UK",
      "abhishektiwari"         => "Amazon, New York, NY, USA",
      "atrisovic"              => "Massachusetts Institute of Technology, Cambridge, MA, USA",
      "adamltyson"             => "Sainsbury Wellcome Centre, University College London, London, UK",

      # ── Topic editors (U) ────────────────────────────────────────────────────
      "adithirgis"             => "University of Liverpool, Liverpool, UK",

      # ── Topic editors (V) ────────────────────────────────────────────────────
      "anastassiavybornova"    => "IT University of Copenhagen, Copenhagen, Denmark",

      # ── Topic editors (W) ────────────────────────────────────────────────────
      "andreww"                => "University of Oxford, Oxford, UK",
      "yuanqing-wang"          => "New York University, New York, NY, USA",
      "rwegener2"              => "Bay Area Environmental Research Institute, Petaluma, CA, USA",
      "britta-wstnr"           => "Radboud University Medical Center, Nijmegen, Netherlands",
      "lucydot"                => "Northumbria University, Newcastle, UK",
      "ethanwhite"             => "University of Florida, Gainesville, FL, USA",
      "erik-whiting"           => "University of Nebraska-Lincoln, Lincoln, NE, USA",
      "fraukewiese"            => "Europa-Universit\u00E4t Flensburg, Flensburg, Germany",

      # ── Topic editors (X–Z) ──────────────────────────────────────────────────
      "fangzhou-xie"           => "Rutgers University, New Brunswick, NJ, USA",
      "yewentao256"            => "Red Hat, Frankfurt, Germany",                          # [VERIFY] location uncertain
      "mengqi-z"               => "Pacific Northwest National Laboratory, Richland, WA, USA",
      "zhubonan"               => "Beijing Institute of Technology, Beijing, China",

      # ── Topic editors (de/f) ─────────────────────────────────────────────────
      "pdebuyl"                => "Royal Meteorological Institute of Belgium, Brussels, Belgium",
      "juliaferraioli"         => "Amazon Web Services, Seattle, WA, USA",
    }

    affiliations.each do |login, affiliation|
      execute "UPDATE editors SET affiliation = #{connection.quote(affiliation)} WHERE lower(login) = #{connection.quote(login.downcase)}"
    end
  end

  def down
    remove_column :editors, :affiliation
  end
end
